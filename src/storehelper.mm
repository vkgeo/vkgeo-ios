#import <StoreKit/StoreKit.h>

#include <cstdlib>

#include "storehelper.h"

StoreHelper::StoreHelper(QObject *parent) : QObject(parent)
{
}

StoreHelper &StoreHelper::GetInstance()
{
    static StoreHelper instance;

    return instance;
}

void StoreHelper::requestReview() const
{
    if (@available(iOS 10.3, *)) {
        [SKStoreReviewController requestReview];
    } else {
        abort();
    }
}
