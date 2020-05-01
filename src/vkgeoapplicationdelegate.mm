#import <UIKit/UIKit.h>

#import <VKSdkFramework/VKSdkFramework.h>

#include <QtCore/QtGlobal>
#include <QtCore/QString>

#include "locationmanagerdelegate.h"

#include "vkgeoapplicationdelegate.h"

static const QString VK_APP_ID(QStringLiteral("6459902")),
                     VK_API_V (QStringLiteral("5.103"));

static LocationManagerDelegate *LocationManagerDelegateInstance = nil;

@interface QIOSApplicationDelegate : UIResponder<UIApplicationDelegate>
@end

@interface QIOSApplicationDelegate (QIOSApplicationDelegateVKGeoCategory)
@end

@implementation QIOSApplicationDelegate (QIOSApplicationDelegateVKGeoCategory)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    Q_UNUSED(application)
    Q_UNUSED(launchOptions)

    [VKSdk initializeWithAppId:VK_APP_ID.toNSString() apiVersion:VK_API_V.toNSString()];

    LocationManagerDelegateInstance = [[LocationManagerDelegate alloc] init];

    return YES;
}

@end

@interface VKGeoApplicationDelegate : QIOSApplicationDelegate
@end

@implementation VKGeoApplicationDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [VKSdk processOpenURL:url fromApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]] ||
           [super application:application openURL:url options:options];
}

@end

static VKGeoApplicationDelegate *VKGeoApplicationDelegateInstance = nil;

void InitializeVKGeoApplicationDelegate()
{
    VKGeoApplicationDelegateInstance = [[VKGeoApplicationDelegate alloc] init];

    UIApplication.sharedApplication.delegate = VKGeoApplicationDelegateInstance;
}
