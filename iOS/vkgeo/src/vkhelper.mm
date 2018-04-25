#import <VKSdkFramework/VKSdkFramework.h>

#include <QtCore/QDebug>

#include "vkhelper.h"

VKHelper *VKHelper::Instance = NULL;

@interface VKDelegate : NSObject<VKSdkDelegate, VKSdkUIDelegate>

- (id)init;
- (void)dealloc;
- (void)login;
- (void)logout;

@property (nonatomic, assign) BOOL Authorized;

@end

@implementation VKDelegate

@synthesize Authorized;

static NSArray *AUTH_SCOPE = @[@"friends", @"notes"];

- (id)init
{
    self = [super init];

    if (self) {
        Authorized = NO;

        [[VKSdk instance] registerDelegate:self];
        [[VKSdk instance] setUiDelegate:self];

        [VKSdk wakeUpSession:AUTH_SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
            if (error) {
                qWarning() << QString::fromNSString([error localizedDescription]);
            } else if (state == VKAuthorizationAuthorized) {
                Authorized = YES;

                VKHelper::setAuthState(VKAuthState::StateAuthorized);
            } else {
                Authorized = NO;

                VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
            }
        }];
    }

    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)login
{
    [VKSdk authorize:AUTH_SCOPE];
}

- (void)logout
{
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result
{
    if (result.error) {
        qWarning() << QString::fromNSString([result.error localizedDescription]);

        Authorized = NO;

        VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
    } else if (result.token) {
        Authorized = YES;

        VKHelper::setAuthState(VKAuthState::StateAuthorized);
    } else {
        Authorized = NO;

        VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
    }
}

- (void)vkSdkUserAuthorizationFailed
{
    Authorized = NO;

    VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
}

- (void)vkSdkAuthorizationStateUpdatedWithResult:(VKAuthorizationResult *)result
{
    if (result.error) {
        qWarning() << QString::fromNSString([result.error localizedDescription]);

        Authorized = NO;

        VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
    } else if (result.token) {
        Authorized = YES;

        VKHelper::setAuthState(VKAuthState::StateAuthorized);
    } else {
        Authorized = NO;

        VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
    }
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken
{
    Q_UNUSED(expiredToken)

    Authorized = NO;

    VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller
{
    UIViewController * __block root_view_controller = nil;

    [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
        root_view_controller = [window rootViewController];

        *stop = (root_view_controller != nil);
    }];

    [root_view_controller presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError
{
    UIViewController * __block root_view_controller = nil;

    [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
        root_view_controller = [window rootViewController];

        *stop = (root_view_controller != nil);
    }];

    VKCaptchaViewController *captcha_view_controller = [[VKCaptchaViewController captchaControllerWithError:captchaError] autorelease];

    [captcha_view_controller presentIn:root_view_controller];
}

@end

VKHelper::VKHelper(QObject *parent) : QObject(parent)
{
    Initialized        = false;
    AuthState          = VKAuthState::StateUnknown;
    Instance           = this;
    VKDelegateInstance = NULL;
}

VKHelper::~VKHelper()
{
    if (Initialized) {
        [VKDelegateInstance release];
    }
}

int VKHelper::authState() const
{
    return AuthState;
}

void VKHelper::initialize()
{
    if (!Initialized) {
        VKDelegateInstance = [[VKDelegate alloc] init];

        Initialized = true;
    }
}

void VKHelper::login()
{
    if (Initialized) {
        [VKDelegateInstance login];
    }
}

void VKHelper::logout()
{
    if (Initialized) {
        [VKDelegateInstance logout];
    }
}

void VKHelper::setAuthState(const int &state)
{
    Instance->AuthState = state;

    emit Instance->authStateChanged(Instance->AuthState);
}
