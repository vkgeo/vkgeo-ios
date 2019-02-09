#include <time.h>

#include <QtCore/QtGlobal>
#include <QtCore/QString>
#include <QtCore/QDebug>

#include "batteryhelpershared.h"
#include "vkhelpershared.h"

#include "locationmanagerdelegate.h"

static const qint64             CENTRAL_LOCATION_CHANGE_TIMEOUT       = 900;
static const NSTimeInterval     LOCATION_ACCURACY_ADJUSTMENT_INTERVAL = 60.0;
static const CLLocationDistance LOCATION_DISTANCE_FILTER              = 100.0,
                                CENTRAL_LOCATION_CHANGE_DISTANCE      = 500.0,
                                CENTRAL_REGION_RADIUS                 = 500.0;

static qint64 elapsedNanos()
{
    struct timespec elapsed_time;

    if (clock_gettime(CLOCK_MONOTONIC_RAW, &elapsed_time) == 0) {
        return static_cast<qint64>(elapsed_time.tv_sec) * 1000000000 + elapsed_time.tv_nsec;
    } else {
        return 0;
    }
}

@implementation LocationManagerDelegate
{
    bool               CentralLocationChanged;
    qint64             CentralLocationChangeHandleNanos;
    CLLocation        *CurrentLocation;
    CLLocation        *CentralLocation;
    CLCircularRegion  *CentralRegion;
    CLLocationManager *LocationManager;
}

- (id)init
{
    self = [super init];

    if (self) {
        CentralLocationChanged           = true;
        CentralLocationChangeHandleNanos = 0;
        CurrentLocation                  = nil;
        CentralLocation                  = nil;
        CentralRegion                    = nil;

        LocationManager = [[CLLocationManager alloc] init];

        LocationManager.allowsBackgroundLocationUpdates    = YES;
        LocationManager.pausesLocationUpdatesAutomatically = NO;
        LocationManager.desiredAccuracy                    = kCLLocationAccuracyNearestTenMeters;
        LocationManager.distanceFilter                     = LOCATION_DISTANCE_FILTER;
        LocationManager.delegate                           = self;

        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [LocationManager startUpdatingLocation];

            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
                if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
                    [LocationManager startMonitoringSignificantLocationChanges];
                }
            }
        }

        [self performSelector:@selector(adjustDesiredAccuracy) withObject:nil afterDelay:LOCATION_ACCURACY_ADJUSTMENT_INTERVAL];
    }

    return self;
}

- (void)dealloc
{
    if (CurrentLocation != nil) {
        [CurrentLocation release];
    }
    if (CentralLocation != nil) {
        [CentralLocation release];
    }
    if (CentralRegion != nil) {
        [CentralRegion release];
    }

    [LocationManager release];

    [super dealloc];
}

- (void)adjustDesiredAccuracy
{
    if (CentralLocationChanged) {
        LocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

        CentralLocationChanged           = false;
        CentralLocationChangeHandleNanos = elapsedNanos();
    } else if (elapsedNanos() - CentralLocationChangeHandleNanos > CENTRAL_LOCATION_CHANGE_TIMEOUT * 1000000000) {
        LocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }

    [self performSelector:@selector(adjustDesiredAccuracy) withObject:nil afterDelay:LOCATION_ACCURACY_ADJUSTMENT_INTERVAL];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    Q_UNUSED(manager)

    if (locations != nil && locations.lastObject != nil) {
        CLLocation *location = locations.lastObject;

        if (CurrentLocation == nil || [CurrentLocation distanceFromLocation:location] > location.horizontalAccuracy) {
            if (CurrentLocation != nil) {
                [CurrentLocation release];
            }

            CurrentLocation = [location retain];

            if (VKHelperShared != nullptr) {
                VKHelperShared->updateLocation(CurrentLocation.coordinate.latitude, CurrentLocation.coordinate.longitude);

                if (BatteryHelperShared != nullptr) {
                    VKHelperShared->updateBatteryStatus(BatteryHelperShared->getBatteryStatus(), BatteryHelperShared->getBatteryLevel());
                }
            }

            if (CentralLocation == nil || [CentralLocation distanceFromLocation:CurrentLocation] > CENTRAL_LOCATION_CHANGE_DISTANCE) {
                if (CentralLocation != nil) {
                    [CentralLocation release];
                }
                if (CentralRegion != nil) {
                    [CentralRegion release];
                }

                CentralLocation        = [CurrentLocation retain];
                CentralRegion          = [[CLCircularRegion alloc] initWithCenter:CentralLocation.coordinate radius:CENTRAL_REGION_RADIUS identifier:@"CENTRAL_REGION"];
                CentralLocationChanged = true;

                if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
                    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
                        [LocationManager startMonitoringForRegion:CentralRegion];
                    }
                }
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    Q_UNUSED(manager)

    qWarning() << QString::fromNSString([error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    Q_UNUSED(manager)
    Q_UNUSED(region)

    qWarning() << QString::fromNSString([error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    Q_UNUSED(manager)

    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        [LocationManager startUpdatingLocation];

        if (status == kCLAuthorizationStatusAuthorizedAlways) {
            if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
                [LocationManager startMonitoringSignificantLocationChanges];
            }

            if (CentralRegion != nil) {
                if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
                    [LocationManager startMonitoringForRegion:CentralRegion];
                }
            }
        } else {
            [LocationManager stopMonitoringSignificantLocationChanges];

            if (CentralRegion != nil) {
                [LocationManager stopMonitoringForRegion:CentralRegion];
            }
        }
    } else {
        [LocationManager stopUpdatingLocation];
        [LocationManager stopMonitoringSignificantLocationChanges];

        if (CentralRegion != nil) {
            [LocationManager stopMonitoringForRegion:CentralRegion];
        }
    }
}

@end
