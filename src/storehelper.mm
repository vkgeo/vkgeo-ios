#import <StoreKit/StoreKit.h>

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
    [SKStoreReviewController requestReview];
}
