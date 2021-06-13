#import <VKSdkFramework/VKSdkFramework.h>

#include <QtCore/QtGlobal>
#include <QtCore/QString>

#include "locationmanagerdelegate.h"

#include "qiosapplicationdelegate.h"

namespace {

const QString VK_APP_ID(QStringLiteral("6459902")),
              VK_API_V (QStringLiteral("5.131"));

LocationManagerDelegate *LocationManagerDelegateInstance = nil;

}

@interface QIOSApplicationDelegate (VKGeo)
@end

@implementation QIOSApplicationDelegate (VKGeo)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    Q_UNUSED(application)
    Q_UNUSED(launchOptions)

    [VKSdk initializeWithAppId:VK_APP_ID.toNSString() apiVersion:VK_API_V.toNSString()];

    LocationManagerDelegateInstance = [[LocationManagerDelegate alloc] init];

    return YES;
}

@end
