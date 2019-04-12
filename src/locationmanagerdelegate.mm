#import <CoreLocation/CLCircularRegion.h>
#import <CoreLocation/CLLocationManager.h>

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
    CLLocationManager *RegularLocationManager,
                      *SignificantChangesLocationManager,
                      *RegionLocationManager;
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

        RegularLocationManager = [[CLLocationManager alloc] init];

        RegularLocationManager.allowsBackgroundLocationUpdates    = YES;
        RegularLocationManager.pausesLocationUpdatesAutomatically = NO;
        RegularLocationManager.desiredAccuracy                    = kCLLocationAccuracyNearestTenMeters;
        RegularLocationManager.distanceFilter                     = LOCATION_DISTANCE_FILTER;
        RegularLocationManager.delegate                           = self;

        SignificantChangesLocationManager = [[CLLocationManager alloc] init];

        SignificantChangesLocationManager.allowsBackgroundLocationUpdates    = YES;
        SignificantChangesLocationManager.pausesLocationUpdatesAutomatically = NO;
        SignificantChangesLocationManager.delegate                           = self;

        RegionLocationManager = [[CLLocationManager alloc] init];

        RegionLocationManager.allowsBackgroundLocationUpdates    = YES;
        RegionLocationManager.pausesLocationUpdatesAutomatically = NO;
        RegionLocationManager.delegate                           = self;

        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [RegularLocationManager startUpdatingLocation];

            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
                if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
                    [SignificantChangesLocationManager startMonitoringSignificantLocationChanges];
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

    [RegularLocationManager            release];
    [SignificantChangesLocationManager release];
    [RegionLocationManager             release];

    [super dealloc];
}

- (void)adjustDesiredAccuracy
{
    if (CentralLocationChanged) {
        RegularLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

        CentralLocationChanged           = false;
        CentralLocationChangeHandleNanos = elapsedNanos();
    } else if (elapsedNanos() - CentralLocationChangeHandleNanos > CENTRAL_LOCATION_CHANGE_TIMEOUT * 1000000000) {
        RegularLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
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
                        [RegionLocationManager startMonitoringForRegion:CentralRegion];
                    }
                }
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    Q_UNUSED(manager)

    qWarning() << QString::fromNSString(error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    Q_UNUSED(manager)
    Q_UNUSED(region)

    qWarning() << QString::fromNSString(error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    Q_UNUSED(manager)

    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        [RegularLocationManager startUpdatingLocation];

        if (status == kCLAuthorizationStatusAuthorizedAlways) {
            if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
                [SignificantChangesLocationManager startMonitoringSignificantLocationChanges];
            }

            if (CentralRegion != nil) {
                if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
                    [RegionLocationManager startMonitoringForRegion:CentralRegion];
                }
            }
        } else {
            [SignificantChangesLocationManager stopMonitoringSignificantLocationChanges];

            if (CentralRegion != nil) {
                [RegionLocationManager stopMonitoringForRegion:CentralRegion];
            }
        }
    } else {
        [RegularLocationManager            stopUpdatingLocation];
        [SignificantChangesLocationManager stopMonitoringSignificantLocationChanges];

        if (CentralRegion != nil) {
            [RegionLocationManager stopMonitoringForRegion:CentralRegion];
        }
    }
}

@end
