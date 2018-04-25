#import <UIKit/UIKit.h>

#import <VKSdkFramework/VKSdkFramework.h>

#include <QtCore/QtGlobal>
#include <QtCore/QString>

static const QString VK_APP_ID("6459902");

@interface QIOSApplicationDelegate : UIResponder <UIApplicationDelegate>
@end

@interface QIOSApplicationDelegate (MyApplicationDelegate)
@end

@implementation QIOSApplicationDelegate (SakuraAppDelegate)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    Q_UNUSED(application)
    Q_UNUSED(launchOptions)

    [VKSdk initializeWithAppId:VK_APP_ID.toNSString()];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    Q_UNUSED(application)

    [VKSdk processOpenURL:url fromApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];

    return YES;
}

@end
