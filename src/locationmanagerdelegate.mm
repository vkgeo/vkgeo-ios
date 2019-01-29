#include <time.h>

#include <QtCore/QtGlobal>
#include <QtCore/QString>
#include <QtCore/QDebug>

#include "batteryhelpershared.h"
#include "vkhelpershared.h"

#include "locationmanagerdelegate.h"

static const qint64             LOCATION_UPDATE_CTR_TIMEOUT           = 900;
static const NSTimeInterval     LOCATION_ACCURACY_ADJUSTMENT_INTERVAL = 60.0;
static const CLLocationDistance LOCATION_DISTANCE_FILTER              = 100.0,
                                LOCATION_UPDATE_CTR_DISTANCE          = 500.0,
                                LOCATION_CTR_REGION_RADIUS            = 500.0;

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
    bool               CenterLocationChanged;
    qint64             CenterLocationChangeHandleNanos;
    CLLocation        *CurrentLocation;
    CLLocation        *CenterLocation;
    CLCircularRegion  *CenterRegion;
    CLLocationManager *LocationManager;
}

- (id)init
{
    self = [super init];

    if (self) {
        CenterLocationChanged           = false;
        CenterLocationChangeHandleNanos = 0;
        CurrentLocation                 = nil;
        CenterLocation                  = nil;
        CenterRegion                    = nil;

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
    if (CenterLocation != nil) {
        [CenterLocation release];
    }

    [LocationManager release];

    [super dealloc];
}

- (void)adjustDesiredAccuracy
{
    if (CenterLocationChanged) {
        LocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

        CenterLocationChanged           = false;
        CenterLocationChangeHandleNanos = elapsedNanos();
    } else if (elapsedNanos() - CenterLocationChangeHandleNanos > LOCATION_UPDATE_CTR_TIMEOUT * 1000000000) {
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

            if (CenterLocation == nil || [CenterLocation distanceFromLocation:CurrentLocation] > LOCATION_UPDATE_CTR_DISTANCE) {
                if (CenterLocation != nil) {
                    [CenterLocation release];
                }

                CenterLocation        = [CurrentLocation retain];
                CenterLocationChanged = true;

                if (CenterRegion != nil) {
                    [CenterRegion release];
                }

                CenterRegion = [[CLCircularRegion alloc] initWithCenter:CenterLocation.coordinate radius:LOCATION_CTR_REGION_RADIUS identifier:@"CENTER_REGION"];

                if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
                    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
                        [LocationManager startMonitoringForRegion:CenterRegion];
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

            if (CenterRegion != nil) {
                if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
                    [LocationManager startMonitoringForRegion:CenterRegion];
                }
            }
        } else {
            [LocationManager stopMonitoringSignificantLocationChanges];

            if (CenterRegion != nil) {
                [LocationManager stopMonitoringForRegion:CenterRegion];
            }
        }
    } else {
        [LocationManager stopUpdatingLocation];
        [LocationManager stopMonitoringSignificantLocationChanges];

        if (CenterRegion != nil) {
            [LocationManager stopMonitoringForRegion:CenterRegion];
        }
    }
}

@end
