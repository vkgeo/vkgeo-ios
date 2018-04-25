#import <GoogleMobileAds/GADMobileAds.h>
#import <GoogleMobileAds/GADRequest.h>
#import <GoogleMobileAds/GADBannerView.h>
#import <GoogleMobileAds/GADBannerViewDelegate.h>
#import <GoogleMobileAds/GADInterstitial.h>
#import <GoogleMobileAds/GADInterstitialDelegate.h>

#include <QtCore/QDebug>

#include "admobhelper.h"

const QString AdMobHelper::ADMOB_APP_ID              ("ca-app-pub-2455088855015693~6963641368");
const QString AdMobHelper::ADMOB_BANNERVIEW_UNIT_ID  ("ca-app-pub-3940256099942544/2934735716");
const QString AdMobHelper::ADMOB_INTERSTITIAL_UNIT_ID("ca-app-pub-3940256099942544/4411468910");
const QString AdMobHelper::ADMOB_TEST_DEVICE_ID      ("");

AdMobHelper *AdMobHelper::Instance = NULL;

@interface BannerViewDelegate : NSObject<GADBannerViewDelegate>

- (id)init;
- (void)dealloc;
- (void)loadAd;

@property (nonatomic, retain) GADBannerView *BannerView;

@end

@implementation BannerViewDelegate

@synthesize BannerView;

- (id)init
{
    self = [super init];

    if (self) {
        UIViewController * __block root_view_controller = nil;

        [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
            root_view_controller = [window rootViewController];

            *stop = (root_view_controller != nil);
        }];

        BannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];

        BannerView.adUnitID                                  = AdMobHelper::ADMOB_BANNERVIEW_UNIT_ID.toNSString();
        BannerView.autoloadEnabled                           = YES;
        BannerView.rootViewController                        = root_view_controller;
        BannerView.translatesAutoresizingMaskIntoConstraints = NO;
        BannerView.delegate                                  = self;

        [root_view_controller.view addSubview:BannerView];

        if (@available(iOS 11, *)) {
            UILayoutGuide *guide = root_view_controller.view.safeAreaLayoutGuide;

            [NSLayoutConstraint activateConstraints:@[
                [BannerView.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],
                [BannerView.bottomAnchor  constraintEqualToAnchor:guide.bottomAnchor]
            ]];

            AdMobHelper::setBannerViewHeight(BannerView.frame.size.height + root_view_controller.view.safeAreaInsets.bottom);
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

- (void)loadAd
{
    GADRequest *request = [GADRequest request];

    if (AdMobHelper::ADMOB_TEST_DEVICE_ID != "") {
        request.testDevices = @[ AdMobHelper::ADMOB_TEST_DEVICE_ID.toNSString() ];
    }

    [self.BannerView loadRequest:request];
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

    qWarning() << QString::fromNSString([error localizedDescription]);

    [self performSelector:@selector(loadAd) withObject:nil afterDelay:10.0];
}

@end

@interface InterstitialDelegate : NSObject<GADInterstitialDelegate>

- (id)init;
- (void)dealloc;
- (void)loadAd;
- (void)show;
- (BOOL)isReady;

@property (nonatomic, retain) GADInterstitial *Interstitial;

@end

@implementation InterstitialDelegate

@synthesize Interstitial;

- (id)init
{
    self = [super init];

    if (self) {
        Interstitial = nil;
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

- (void)loadAd
{
    if (self.Interstitial != nil) {
        [self.Interstitial release];
    }

    self.Interstitial = [[GADInterstitial alloc] initWithAdUnitID:AdMobHelper::ADMOB_INTERSTITIAL_UNIT_ID.toNSString()];

    self.Interstitial.delegate = self;

    GADRequest *request = [GADRequest request];

    if (AdMobHelper::ADMOB_TEST_DEVICE_ID != "") {
        request.testDevices = @[ AdMobHelper::ADMOB_TEST_DEVICE_ID.toNSString() ];
    }

    [self.Interstitial loadRequest:request];
}

- (void)show
{
    if (self.Interstitial != nil && self.Interstitial.isReady) {
        UIViewController * __block root_view_controller = nil;

        [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
            root_view_controller = [window rootViewController];

            *stop = (root_view_controller != nil);
        }];

        [self.Interstitial presentFromRootViewController:root_view_controller];
    }
}

- (BOOL)isReady
{
    if (self.Interstitial != nil) {
        return self.Interstitial.isReady;
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

    AdMobHelper::setInterstitialActive(true);
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    Q_UNUSED(ad)
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    Q_UNUSED(ad)

    AdMobHelper::setInterstitialActive(false);

    [self performSelector:@selector(loadAd) withObject:nil afterDelay:10.0];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    Q_UNUSED(ad)
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    Q_UNUSED(ad)

    qWarning() << QString::fromNSString([error localizedDescription]);

    [self performSelector:@selector(loadAd) withObject:nil afterDelay:10.0];
}

@end

AdMobHelper::AdMobHelper(QObject *parent) : QObject(parent)
{
    Initialized                  = false;
    InterstitialActive           = false;
    BannerViewHeight             = 0;
    Instance                     = this;
    BannerViewDelegateInstance   = NULL;
    InterstitialDelegateInstance = NULL;
}

AdMobHelper::~AdMobHelper()
{
    if (Initialized) {
        if (BannerViewDelegateInstance != NULL && BannerViewDelegateInstance != nil) {
            [BannerViewDelegateInstance release];
        }

        [InterstitialDelegateInstance release];
    }
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

void AdMobHelper::initialize()
{
    if (!Initialized) {
        [GADMobileAds configureWithApplicationID:ADMOB_APP_ID.toNSString()];

        InterstitialDelegateInstance = [[InterstitialDelegate alloc] init];

        [InterstitialDelegateInstance loadAd];

        Initialized = true;
    }
}

void AdMobHelper::showBannerView()
{
    if (Initialized) {
        if (BannerViewDelegateInstance != NULL && BannerViewDelegateInstance != nil) {
            [BannerViewDelegateInstance release];

            BannerViewHeight = 0;

            emit bannerViewHeightChanged(BannerViewHeight);

            BannerViewDelegateInstance = nil;
        }

        BannerViewDelegateInstance = [[BannerViewDelegate alloc] init];

        [BannerViewDelegateInstance loadAd];
    }
}

void AdMobHelper::hideBannerView()
{
    if (Initialized) {
        if (BannerViewDelegateInstance != NULL && BannerViewDelegateInstance != nil) {
            [BannerViewDelegateInstance release];

            BannerViewHeight = 0;

            emit bannerViewHeightChanged(BannerViewHeight);

            BannerViewDelegateInstance = nil;
        }
    }
}

void AdMobHelper::showInterstitial()
{
    if (Initialized) {
        [InterstitialDelegateInstance show];
    }
}

void AdMobHelper::setInterstitialActive(const bool &active)
{
    Instance->InterstitialActive = active;

    emit Instance->interstitialActiveChanged(Instance->InterstitialActive);
}

void AdMobHelper::setBannerViewHeight(const int &height)
{
    Instance->BannerViewHeight = height;

    emit Instance->bannerViewHeightChanged(Instance->BannerViewHeight);
}
