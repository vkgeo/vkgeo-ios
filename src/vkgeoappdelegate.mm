#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

#import <VKSdkFramework/VKSdkFramework.h>

#include <time.h>

#include <QtCore/QtGlobal>
#include <QtCore/QString>
#include <QtCore/QDebug>

#include "batteryhelpershared.h"
#include "vkhelpershared.h"

static const qint64             LOCATION_UPDATE_CTR_TIMEOUT          = 900;
static const NSTimeInterval     DESIRED_ACCURACY_ADJUSTMENT_INTERVAL = 60.0;
static const CLLocationDistance LOCATION_DISTANCE_FILTER             = 100.0,
                                LOCATION_UPDATE_CTR_DISTANCE         = 500.0;
static const QString            VK_APP_ID("6459902"),
                                VK_API_V("5.80");

static bool               CenterLocationChanged           = false;
static qint64             CenterLocationChangeHandleNanos = 0;
static CLLocation        *CurrentLocation                 = nil,
                         *CenterLocation                  = nil;
static CLLocationManager *LocationManager                 = nil;

static qint64 elapsedNanos()
{
    struct timespec elapsed_time;

    if (clock_gettime(CLOCK_MONOTONIC_RAW, &elapsed_time) == 0) {
        return static_cast<qint64>(elapsed_time.tv_sec) * 1000000000 + elapsed_time.tv_nsec;
    } else {
        return 0;
    }
}

@interface QIOSApplicationDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
@end

@interface QIOSApplicationDelegate (VKGeoAppDelegate)
@end

@implementation QIOSApplicationDelegate (VKGeoAppDelegate)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    Q_UNUSED(application)
    Q_UNUSED(launchOptions)

    [VKSdk initializeWithAppId:VK_APP_ID.toNSString() apiVersion:VK_API_V.toNSString()];

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

    [self performSelector:@selector(adjustDesiredAccuracy) withObject:nil afterDelay:DESIRED_ACCURACY_ADJUSTMENT_INTERVAL];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    Q_UNUSED(application)

    [VKSdk processOpenURL:url fromApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];

    return YES;
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
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    Q_UNUSED(manager)

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
        } else {
            [LocationManager stopMonitoringSignificantLocationChanges];
        }
    } else {
        [LocationManager stopUpdatingLocation];
        [LocationManager stopMonitoringSignificantLocationChanges];
    }
}

- (void)adjustDesiredAccuracy
{
    if (CenterLocationChanged) {
        LocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

        CenterLocationChanged           = false;
        CenterLocationChangeHandleNanos = elapsedNanos();
    } else if (elapsedNanos() - CenterLocationChangeHandleNanos > LOCATION_UPDATE_CTR_TIMEOUT * 1000000000) {
        LocationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    }

    [self performSelector:@selector(adjustDesiredAccuracy) withObject:nil afterDelay:DESIRED_ACCURACY_ADJUSTMENT_INTERVAL];
}

@end
