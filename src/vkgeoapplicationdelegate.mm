#import <VKSdkFramework/VKSdkFramework.h>

#include "qiosapplicationdelegate.h"

#include "vkgeoapplicationdelegate.h"

@interface VKGeoApplicationDelegate : QIOSApplicationDelegate
@end

@implementation VKGeoApplicationDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [VKSdk processOpenURL:url fromApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]] ||
           [super application:application openURL:url options:options];
}

@end

namespace {

VKGeoApplicationDelegate *VKGeoApplicationDelegateInstance = nil;

}

void InitializeVKGeoApplicationDelegate()
{
    VKGeoApplicationDelegateInstance = [[VKGeoApplicationDelegate alloc] init];

    UIApplication.sharedApplication.delegate = VKGeoApplicationDelegateInstance;
}
