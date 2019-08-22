#ifndef ADMOBHELPER_H
#define ADMOBHELPER_H

#include <QtCore/QObject>
#include <QtCore/QString>

#ifdef __OBJC__
@class BannerViewDelegate;
@class InterstitialDelegate;
#endif

class AdMobHelper : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool interstitialReady  READ interstitialReady)
    Q_PROPERTY(bool interstitialActive READ interstitialActive NOTIFY interstitialActiveChanged)
    Q_PROPERTY(int  bannerViewHeight   READ bannerViewHeight   NOTIFY bannerViewHeightChanged)

private:
    explicit AdMobHelper(QObject *parent = nullptr);
    ~AdMobHelper() noexcept override;

public:
    static const QString ADMOB_BANNERVIEW_UNIT_ID,
                         ADMOB_INTERSTITIAL_UNIT_ID,
                         ADMOB_TEST_DEVICE_ID;

    AdMobHelper(const AdMobHelper &) = delete;
    AdMobHelper(AdMobHelper &&) noexcept = delete;

    AdMobHelper &operator=(const AdMobHelper &) = delete;
    AdMobHelper &operator=(AdMobHelper &&) noexcept = delete;

    static AdMobHelper &GetInstance();

    bool interstitialReady() const;
    bool interstitialActive() const;
    int bannerViewHeight() const;

    Q_INVOKABLE void initAds();

    Q_INVOKABLE void setPersonalization(bool personalized);

    Q_INVOKABLE void showBannerView();
    Q_INVOKABLE void hideBannerView();

    Q_INVOKABLE void showInterstitial();

    void setInterstitialActive(bool active);
    void setBannerViewHeight(int height);

signals:
    void interstitialActiveChanged(bool interstitialActive);
    void bannerViewHeightChanged(int bannerViewHeight);

private:
    bool                  Initialized, ShowPersonalizedAds, InterstitialActive;
    int                   BannerViewHeight;
#ifdef __OBJC__
    BannerViewDelegate   *BannerViewDelegateInstance;
    InterstitialDelegate *InterstitialDelegateInstance;
#else
    void                 *BannerViewDelegateInstance;
    void                 *InterstitialDelegateInstance;
#endif
};

#endif // ADMOBHELPER_H
