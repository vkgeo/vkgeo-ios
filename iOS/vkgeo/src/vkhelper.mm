#import <VKSdkFramework/VKSdkFramework.h>

#include <QtCore/QDebug>

#include "vkhelper.h"

const QString VKHelper::DEFAULT_PHOTO_URL("https://vk.com/images/camera_50.png");

static NSArray *AUTH_SCOPE = @[@"friends", @"notes"];

VKHelper *VKHelper::Instance = NULL;

@interface VKDelegate : NSObject<VKSdkDelegate, VKSdkUIDelegate>

- (id)init;
- (void)dealloc;

@end

@implementation VKDelegate

- (id)init
{
    self = [super init];

    if (self) {
        [[VKSdk instance] registerDelegate:self];
        [[VKSdk instance] setUiDelegate:self];

        [VKSdk wakeUpSession:AUTH_SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
            if (error != nil) {
                qWarning() << QString::fromNSString([error localizedDescription]);

                VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
            } else if (state == VKAuthorizationAuthorized) {
                VKHelper::setAuthState(VKAuthState::StateAuthorized);
            } else {
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

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result
{
    if (result.error != nil) {
        qWarning() << QString::fromNSString([result.error localizedDescription]);

        VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
    } else if (result.token != nil) {
        VKHelper::setAuthState(VKAuthState::StateAuthorized);
    } else {
        VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
    }
}

- (void)vkSdkUserAuthorizationFailed
{
    VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
}

- (void)vkSdkAuthorizationStateUpdatedWithResult:(VKAuthorizationResult *)result
{
    if (result.error != nil) {
        qWarning() << QString::fromNSString([result.error localizedDescription]);

        VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
    } else if (result.token != nil) {
        VKHelper::setAuthState(VKAuthState::StateAuthorized);
    } else {
        VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
    }
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken
{
    Q_UNUSED(expiredToken)

    VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller
{
    UIViewController * __block root_view_controller = nil;

    [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
        root_view_controller = [window rootViewController];

        *stop = (root_view_controller != nil);
    }];

    if (root_view_controller != nil) {
        [root_view_controller presentViewController:controller animated:YES completion:nil];
    }
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError
{
    UIViewController * __block root_view_controller = nil;

    [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
        root_view_controller = [window rootViewController];

        *stop = (root_view_controller != nil);
    }];

    if (root_view_controller != nil) {
        VKCaptchaViewController *captcha_view_controller = [[VKCaptchaViewController captchaControllerWithError:captchaError] autorelease];

        [captcha_view_controller presentIn:root_view_controller];
    }
}

@end

VKHelper::VKHelper(QObject *parent) : QObject(parent)
{
    Initialized        = false;
    AuthState          = VKAuthState::StateUnknown;
    PhotoUrl           = DEFAULT_PHOTO_URL;
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

QString VKHelper::photoUrl() const
{
    return PhotoUrl;
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
        [VKSdk authorize:AUTH_SCOPE];
    }
}

void VKHelper::logout()
{
    if (Initialized) {
        [VKSdk forceLogout];

        setAuthState(VKAuthState::StateNotAuthorized);
    }
}

void VKHelper::setAuthState(const int &state)
{
    Instance->AuthState = state;

    emit Instance->authStateChanged(Instance->AuthState);

    if (Instance->AuthState == VKAuthState::StateAuthorized) {
        VKAccessToken *token = [VKSdk accessToken];

        if (token != nil && token.localUser != nil && token.localUser.photo_50 != nil) {
            Instance->PhotoUrl = QString::fromNSString(token.localUser.photo_50);
        } else {
            Instance->PhotoUrl = DEFAULT_PHOTO_URL;
        }
    } else {
        Instance->PhotoUrl = DEFAULT_PHOTO_URL;
    }

    emit Instance->photoUrlChanged(Instance->PhotoUrl);
}
