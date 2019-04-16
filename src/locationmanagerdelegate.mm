#import <CoreLocation/CoreLocation.h>

#include <ctime>

#include <QtCore/QtGlobal>
#include <QtCore/QString>
#include <QtCore/QDebug>

#include "batteryhelpershared.h"
#include "vkhelpershared.h"

#include "locationmanagerdelegate.h"

static const qint64             CENTRAL_LOCATION_CHANGE_TIMEOUT       = 900;
static const NSTimeInterval     LOCATION_ACCURACY_ADJUSTMENT_INTERVAL = 60.0;
static const CLLocationDistance CURRENT_LOCATION_CHANGE_DISTANCE      = 100.0,
                                CURRENT_REGION_RADIUS                 = 100.0,
                                CENTRAL_LOCATION_CHANGE_DISTANCE      = 500.0;

static qint64 elapsedNanos()
{
    struct timespec elapsed_time = {};

    if (@available(iOS 10, *)) {
        if (clock_gettime(CLOCK_MONOTONIC_RAW, &elapsed_time) == 0) {
            return static_cast<qint64>(elapsed_time.tv_sec) * 1000000000 + elapsed_time.tv_nsec;
        } else {
            return 0;
        }
    } else {
        assert(0);
    }
}

@implementation LocationManagerDelegate
{
    bool               CentralLocationChanged;
    qint64             CentralLocationChangeHandleNanos;
    CLLocation        *CurrentLocation;
    CLCircularRegion  *CurrentRegion API_AVAILABLE(ios(7));
    CLLocation        *CentralLocation;
    CLLocationManager *LocationManager;
}

- (id)init
{
    self = [super init];

    if (self) {
        CentralLocationChanged           = true;
        CentralLocationChangeHandleNanos = 0;
        CurrentLocation                  = nil;
        CurrentRegion                    = nil;
        CentralLocation                  = nil;

        if (@available(iOS 9, *)) {
            LocationManager = [[CLLocationManager alloc] init];

            LocationManager.allowsBackgroundLocationUpdates    = YES;
            LocationManager.pausesLocationUpdatesAutomatically = NO;
            LocationManager.desiredAccuracy                    = kCLLocationAccuracyNearestTenMeters;
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
        } else {
            assert(0);
        }
    }

    return self;
}

- (void)dealloc
{
    if (CurrentLocation != nil) {
        [CurrentLocation release];
    }
    if (CurrentRegion != nil) {
        [CurrentRegion release];
    }
    if (CentralLocation != nil) {
        [CentralLocation release];
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

        if (CurrentLocation == nil || ([CurrentLocation distanceFromLocation:location] > location.horizontalAccuracy &&
                                       [CurrentLocation distanceFromLocation:location] > CURRENT_LOCATION_CHANGE_DISTANCE)) {
            if (CurrentLocation != nil) {
                [CurrentLocation release];
            }
            if (CurrentRegion != nil) {
                [CurrentRegion release];
            }

            if (@available(iOS 8, *)) {
                CurrentLocation = [location retain];
                CurrentRegion   = [[CLCircularRegion alloc] initWithCenter:CurrentLocation.coordinate radius:CURRENT_REGION_RADIUS identifier:@"CURRENT_REGION"];

                if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
                    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
                        [LocationManager startMonitoringForRegion:CurrentRegion];
                    }
                }

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

                    CentralLocation        = [CurrentLocation retain];
                    CentralLocationChanged = true;
                }
            } else {
                assert(0);
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    Q_UNUSED(manager)

    qWarning() << QString::fromNSString(error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    Q_UNUSED(manager)

    if (CurrentRegion != nil && [CurrentRegion.identifier isEqualToString:region.identifier]) {
        CLLocation *location = LocationManager.location;

        if (location != nil) {
            if (CurrentLocation == nil || [CurrentLocation.timestamp compare:location.timestamp] == NSOrderedAscending) {
                if (@available(iOS 6, *)) {
                    [self locationManager:LocationManager didUpdateLocations:@[location]];
                } else {
                    assert(0);
                }
            }
        }
    }
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

    if (@available(iOS 8, *)) {
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
            status == kCLAuthorizationStatusAuthorizedAlways) {
            [LocationManager startUpdatingLocation];

            if (status == kCLAuthorizationStatusAuthorizedAlways) {
                if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
                    [LocationManager startMonitoringSignificantLocationChanges];
                }

                if (CurrentRegion != nil) {
                    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
                        [LocationManager startMonitoringForRegion:CurrentRegion];
                    }
                }
            } else {
                [LocationManager stopMonitoringSignificantLocationChanges];

                if (CurrentRegion != nil) {
                    [LocationManager stopMonitoringForRegion:CurrentRegion];
                }
            }
        } else {
            [LocationManager stopUpdatingLocation];
            [LocationManager stopMonitoringSignificantLocationChanges];

            if (CurrentRegion != nil) {
                [LocationManager stopMonitoringForRegion:CurrentRegion];
            }
        }
    } else {
        assert(0);
    }
}

@end
