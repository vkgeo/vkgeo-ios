#import <UIKit/UIKit.h>

#import <GoogleMobileAds/GoogleMobileAds.h>

#include <QtCore/QtGlobal>
#include <QtCore/QtMath>
#include <QtCore/QLatin1String>
#include <QtCore/QDebug>

#include "admobhelper.h"

const QString AdMobHelper::ADMOB_BANNERVIEW_UNIT_ID  (QStringLiteral("ca-app-pub-2455088855015693/6159186300"));
const QString AdMobHelper::ADMOB_INTERSTITIAL_UNIT_ID(QStringLiteral("ca-app-pub-2455088855015693/6215026625"));
const QString AdMobHelper::ADMOB_TEST_DEVICE_ID      (QLatin1String(""));

namespace {

constexpr NSTimeInterval AD_RELOAD_ON_FAILURE_DELAY = 60.0;

}

@interface BannerViewDelegate : NSObject<GADBannerViewDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHelper:(AdMobHelper *)helper NS_DESIGNATED_INITIALIZER;
- (void)dealloc;
- (void)removeHelperAndAutorelease;
- (void)setPersonalization:(BOOL)personalized;
- (void)loadAd;

@end

@implementation BannerViewDelegate
{
    BOOL           ShowPersonalizedAds;
    GADBannerView *BannerView;
    AdMobHelper   *AdMobHelperInstance;
}

- (instancetype)initWithHelper:(AdMobHelper *)helper
{
    self = [super init];

    if (self != nil) {
        ShowPersonalizedAds = NO;
        AdMobHelperInstance = helper;

        UIViewController * __block root_view_controller = nil;

        [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
            root_view_controller = window.rootViewController;

            *stop = (root_view_controller != nil);
        }];

        BannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];

        BannerView.adUnitID                                  = AdMobHelper::ADMOB_BANNERVIEW_UNIT_ID.toNSString();
        BannerView.autoloadEnabled                           = YES;
        BannerView.translatesAutoresizingMaskIntoConstraints = NO;
        BannerView.rootViewController                        = root_view_controller;
        BannerView.delegate                                  = self;
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

- (void)setPersonalization:(BOOL)personalized
{
    ShowPersonalizedAds = personalized;
}

- (void)loadAd
{
    GADRequest *request = [GADRequest request];

    if (!ShowPersonalizedAds) {
        GADExtras *extras = [[[GADExtras alloc] init] autorelease];

        extras.additionalParameters = @{@"npa": @"1"};

        [request registerAdNetworkExtras:extras];
    }

    [BannerView loadRequest:request];
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView
{
    Q_UNUSED(adView)

    UIViewController * __block root_view_controller = nil;

    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
        root_view_controller = window.rootViewController;

        *stop = (root_view_controller != nil);
    }];

    [root_view_controller.view addSubview:BannerView];

    UILayoutGuide *guide = root_view_controller.view.safeAreaLayoutGuide;

    [NSLayoutConstraint activateConstraints:@[
        [BannerView.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],
        [BannerView.topAnchor     constraintEqualToAnchor:guide.topAnchor]
    ]];

    CGSize  status_bar_size   = UIApplication.sharedApplication.statusBarFrame.size;
    CGFloat status_bar_height = qMin(status_bar_size.width, status_bar_size.height);

    if (AdMobHelperInstance != nullptr) {
        AdMobHelperInstance->SetBannerViewHeight(qFloor(BannerView.frame.size.height + root_view_controller.view.safeAreaInsets.top
                                                                                     - status_bar_height));
    }
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

    [self performSelector:@selector(loadAd) withObject:nil afterDelay:AD_RELOAD_ON_FAILURE_DELAY];
}

@end

@interface InterstitialDelegate : NSObject<GADInterstitialDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHelper:(AdMobHelper *)helper NS_DESIGNATED_INITIALIZER;
- (void)dealloc;
- (void)removeHelperAndAutorelease;
- (void)setPersonalization:(BOOL)personalized;
- (void)loadAd;
- (void)show;
- (BOOL)isReady;

@end

@implementation InterstitialDelegate
{
    BOOL             ShowPersonalizedAds;
    GADInterstitial *Interstitial;
    AdMobHelper     *AdMobHelperInstance;
}

- (instancetype)initWithHelper:(AdMobHelper *)helper
{
    self = [super init];

    if (self != nil) {
        ShowPersonalizedAds = NO;
        Interstitial        = nil;
        AdMobHelperInstance = helper;
    }

    return self;
}

- (void)dealloc
{
    [Interstitial release];

    [super dealloc];
}

- (void)removeHelperAndAutorelease
{
    AdMobHelperInstance = nullptr;

    [self autorelease];
}

- (void)setPersonalization:(BOOL)personalized
{
    ShowPersonalizedAds = personalized;
}

- (void)loadAd
{
    [Interstitial release];

    Interstitial = [[GADInterstitial alloc] initWithAdUnitID:AdMobHelper::ADMOB_INTERSTITIAL_UNIT_ID.toNSString()];

    Interstitial.delegate = self;

    GADRequest *request = [GADRequest request];

    if (!ShowPersonalizedAds) {
        GADExtras *extras = [[[GADExtras alloc] init] autorelease];

        extras.additionalParameters = @{@"npa": @"1"};

        [request registerAdNetworkExtras:extras];
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
        AdMobHelperInstance->SetInterstitialActive(true);
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
        AdMobHelperInstance->SetInterstitialActive(false);
    }

    [self performSelector:@selector(loadAd) withObject:nil afterDelay:0.0];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    Q_UNUSED(ad)
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    Q_UNUSED(ad)

    qWarning() << QString::fromNSString(error.localizedDescription);

    [self performSelector:@selector(loadAd) withObject:nil afterDelay:AD_RELOAD_ON_FAILURE_DELAY];
}

@end

AdMobHelper::AdMobHelper(QObject *parent) :
    QObject                     (parent),
    Initialized                 (false),
    ShowPersonalizedAds         (false),
    InterstitialActive          (false),
    BannerViewHeight            (0),
    BannerViewDelegateInstance  (nil),
    InterstitialDelegateInstance(nil)
{
}

AdMobHelper::~AdMobHelper() noexcept
{
    [BannerViewDelegateInstance   removeHelperAndAutorelease];
    [InterstitialDelegateInstance removeHelperAndAutorelease];
}

AdMobHelper &AdMobHelper::GetInstance()
{
    static AdMobHelper instance;

    return instance;
}

bool AdMobHelper::interstitialReady() const
{
    if (Initialized) {
        return [InterstitialDelegateInstance isReady];
    } else {
        return false;
    }
}

bool AdMobHelper::interstitialActive() const
{
    return InterstitialActive;
}

int AdMobHelper::bannerViewHeight() const
{
    return BannerViewHeight;
}

void AdMobHelper::initAds()
{
    if (!Initialized) {
        [GADMobileAds sharedInstance].requestConfiguration.maxAdContentRating = GADMaxAdContentRatingGeneral;

        if (AdMobHelper::ADMOB_TEST_DEVICE_ID != QLatin1String("")) {
            [GADMobileAds sharedInstance].requestConfiguration.testDeviceIdentifiers = @[AdMobHelper::ADMOB_TEST_DEVICE_ID.toNSString()];
        }

        [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];

        InterstitialDelegateInstance = [[InterstitialDelegate alloc] initWithHelper:this];

        [InterstitialDelegateInstance setPersonalization:ShowPersonalizedAds];
        [InterstitialDelegateInstance loadAd];

        Initialized = true;
    }
}

void AdMobHelper::setPersonalization(bool personalized)
{
    ShowPersonalizedAds = personalized;

    if (Initialized) {
        [BannerViewDelegateInstance   setPersonalization:ShowPersonalizedAds];
        [InterstitialDelegateInstance setPersonalization:ShowPersonalizedAds];
    }
}

void AdMobHelper::showBannerView()
{
    if (Initialized) {
        [BannerViewDelegateInstance removeHelperAndAutorelease];

        if (BannerViewHeight != 0) {
            BannerViewHeight = 0;

            emit bannerViewHeightChanged(BannerViewHeight);
        }

        BannerViewDelegateInstance = [[BannerViewDelegate alloc] initWithHelper:this];

        [BannerViewDelegateInstance setPersonalization:ShowPersonalizedAds];
        [BannerViewDelegateInstance loadAd];
    }
}

void AdMobHelper::hideBannerView()
{
    if (Initialized) {
        [BannerViewDelegateInstance removeHelperAndAutorelease];

        if (BannerViewHeight != 0) {
            BannerViewHeight = 0;

            emit bannerViewHeightChanged(BannerViewHeight);
        }

        BannerViewDelegateInstance = nil;
    }
}

void AdMobHelper::showInterstitial() const
{
    if (Initialized) {
        [InterstitialDelegateInstance show];
    }
}

void AdMobHelper::SetInterstitialActive(bool active)
{
    if (InterstitialActive != active) {
        InterstitialActive = active;

        emit interstitialActiveChanged(InterstitialActive);
    }
}

void AdMobHelper::SetBannerViewHeight(int height)
{
    if (BannerViewHeight != height) {
        BannerViewHeight = height;

        emit bannerViewHeightChanged(BannerViewHeight);
    }
}
