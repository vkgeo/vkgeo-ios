#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#include <QtCore/QtGlobal>
#include <QtCore/QtMath>
#include <QtCore/QDebug>

#include "admobhelper.h"

const QString AdMobHelper::ADMOB_APP_ID              ("ca-app-pub-2455088855015693~9304224395");
const QString AdMobHelper::ADMOB_BANNERVIEW_UNIT_ID  ("ca-app-pub-2455088855015693/6159186300");
const QString AdMobHelper::ADMOB_INTERSTITIAL_UNIT_ID("ca-app-pub-2455088855015693/6215026625");
const QString AdMobHelper::ADMOB_TEST_DEVICE_ID      ("");

@interface BannerViewDelegate : NSObject<GADBannerViewDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHelper:(AdMobHelper *)helper NS_DESIGNATED_INITIALIZER;
- (void)dealloc;
- (void)removeHelperAndAutorelease;
- (void)loadAd;

@end

@implementation BannerViewDelegate
{
    GADBannerView *BannerView;
    AdMobHelper   *AdMobHelperInstance;
}

- (instancetype)initWithHelper:(AdMobHelper *)helper
{
    self = [super init];

    if (self != nil) {
        AdMobHelperInstance = helper;

        UIViewController * __block root_view_controller = nil;

        [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
            root_view_controller = window.rootViewController;

            *stop = (root_view_controller != nil);
        }];

        BannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];

        BannerView.adUnitID           = AdMobHelper::ADMOB_BANNERVIEW_UNIT_ID.toNSString();
        BannerView.autoloadEnabled    = YES;
        BannerView.rootViewController = root_view_controller;
        BannerView.delegate           = self;

        if (@available(iOS 6, *)) {
            BannerView.translatesAutoresizingMaskIntoConstraints = NO;
        } else {
            assert(0);
        }

        [root_view_controller.view addSubview:BannerView];

        if (@available(iOS 11, *)) {
            UILayoutGuide *guide = root_view_controller.view.safeAreaLayoutGuide;

            [NSLayoutConstraint activateConstraints:@[
                [BannerView.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],
                [BannerView.topAnchor     constraintEqualToAnchor:guide.topAnchor]
            ]];

            CGSize  status_bar_size   = UIApplication.sharedApplication.statusBarFrame.size;
            CGFloat status_bar_height = qMin(status_bar_size.width, status_bar_size.height);

            if (AdMobHelperInstance != nullptr) {
                AdMobHelperInstance->setBannerViewHeight(qFloor(BannerView.frame.size.height + root_view_controller.view.safeAreaInsets.top
                                                                                             - status_bar_height));
            }
        } else {
            assert(0);
        }
    }

    return self;
}

- (void)dealloc
{
    [BannerView removeFromSuperview];
    [BannerView release];

    [super dealloc];
}

- (void)removeHelperAndAutorelease
{
    AdMobHelperInstance = nullptr;

    [self autorelease];
}

- (void)loadAd
{
    GADRequest *request = [GADRequest request];

    if (AdMobHelper::ADMOB_TEST_DEVICE_ID != "") {
        request.testDevices = @[ AdMobHelper::ADMOB_TEST_DEVICE_ID.toNSString() ];
    }

    [BannerView loadRequest:request];
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView
{
    Q_UNUSED(adView)
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView
{
    Q_UNUSED(adView)
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView
{
    Q_UNUSED(adView)
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView
{
    Q_UNUSED(adView)
}

- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error
{
    Q_UNUSED(adView)

    qWarning() << QString::fromNSString(error.localizedDescription);

    [self performSelector:@selector(loadAd) withObject:nil afterDelay:10.0];
}

@end

@interface InterstitialDelegate : NSObject<GADInterstitialDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHelper:(AdMobHelper *)helper NS_DESIGNATED_INITIALIZER;
- (void)dealloc;
- (void)removeHelperAndAutorelease;
- (void)loadAd;
- (void)show;
- (BOOL)isReady;

@end

@implementation InterstitialDelegate
{
    GADInterstitial *Interstitial;
    AdMobHelper     *AdMobHelperInstance;
}

- (instancetype)initWithHelper:(AdMobHelper *)helper
{
    self = [super init];

    if (self != nil) {
        Interstitial        = nil;
        AdMobHelperInstance = helper;
    }

    return self;
}

- (void)dealloc
{
    if (Interstitial != nil) {
        [Interstitial release];
    }

    [super dealloc];
}

- (void)removeHelperAndAutorelease
{
    AdMobHelperInstance = nullptr;

    [self autorelease];
}

- (void)loadAd
{
    if (Interstitial != nil) {
        [Interstitial release];
    }

    Interstitial = [[GADInterstitial alloc] initWithAdUnitID:AdMobHelper::ADMOB_INTERSTITIAL_UNIT_ID.toNSString()];

    Interstitial.delegate = self;

    GADRequest *request = [GADRequest request];

    if (AdMobHelper::ADMOB_TEST_DEVICE_ID != "") {
        request.testDevices = @[ AdMobHelper::ADMOB_TEST_DEVICE_ID.toNSString() ];
    }

    [Interstitial loadRequest:request];
}

- (void)show
{
    if (Interstitial != nil && Interstitial.isReady) {
        UIViewController * __block root_view_controller = nil;

        [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
            root_view_controller = window.rootViewController;

            *stop = (root_view_controller != nil);
        }];

        [Interstitial presentFromRootViewController:root_view_controller];
    }
}

- (BOOL)isReady
{
    if (Interstitial != nil) {
        return Interstitial.isReady;
    } else {
        return NO;
    }
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    Q_UNUSED(ad)
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
    Q_UNUSED(ad)

    if (AdMobHelperInstance != nullptr) {
        AdMobHelperInstance->setInterstitialActive(true);
    }
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    Q_UNUSED(ad)
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    Q_UNUSED(ad)

    if (AdMobHelperInstance != nullptr) {
        AdMobHelperInstance->setInterstitialActive(false);
    }

    [self performSelector:@selector(loadAd) withObject:nil afterDelay:10.0];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    Q_UNUSED(ad)
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    Q_UNUSED(ad)

    qWarning() << QString::fromNSString(error.localizedDescription);

    [self performSelector:@selector(loadAd) withObject:nil afterDelay:10.0];
}

@end

AdMobHelper::AdMobHelper(QObject *parent) : QObject(parent)
{
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];

    InterstitialActive           = false;
    BannerViewHeight             = 0;
    BannerViewDelegateInstance   = nullptr;
    InterstitialDelegateInstance = [[InterstitialDelegate alloc] initWithHelper:this];

    [InterstitialDelegateInstance loadAd];
}

AdMobHelper::~AdMobHelper() noexcept
{
    if (BannerViewDelegateInstance != nullptr && BannerViewDelegateInstance != nil) {
        [BannerViewDelegateInstance removeHelperAndAutorelease];
    }

    [InterstitialDelegateInstance removeHelperAndAutorelease];
}

AdMobHelper &AdMobHelper::GetInstance()
{
    static AdMobHelper instance;

    return instance;
}

bool AdMobHelper::interstitialReady() const
{
    return [InterstitialDelegateInstance isReady];
}

bool AdMobHelper::interstitialActive() const
{
    return InterstitialActive;
}

int AdMobHelper::bannerViewHeight() const
{
    return BannerViewHeight;
}

void AdMobHelper::showBannerView()
{
    if (BannerViewDelegateInstance != nullptr && BannerViewDelegateInstance != nil) {
        [BannerViewDelegateInstance removeHelperAndAutorelease];

        BannerViewHeight = 0;

        emit bannerViewHeightChanged(BannerViewHeight);

        BannerViewDelegateInstance = nil;
    }

    BannerViewDelegateInstance = [[BannerViewDelegate alloc] initWithHelper:this];

    [BannerViewDelegateInstance loadAd];
}

void AdMobHelper::hideBannerView()
{
    if (BannerViewDelegateInstance != nullptr && BannerViewDelegateInstance != nil) {
        [BannerViewDelegateInstance removeHelperAndAutorelease];

        BannerViewHeight = 0;

        emit bannerViewHeightChanged(BannerViewHeight);

        BannerViewDelegateInstance = nil;
    }
}

void AdMobHelper::showInterstitial()
{
    [InterstitialDelegateInstance show];
}

void AdMobHelper::setInterstitialActive(bool active)
{
    InterstitialActive = active;

    emit interstitialActiveChanged(InterstitialActive);
}

void AdMobHelper::setBannerViewHeight(int height)
{
    BannerViewHeight = height;

    emit bannerViewHeightChanged(BannerViewHeight);
}
