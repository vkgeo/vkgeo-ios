#import <UIKit/UIWindow.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIViewController.h>

#include <QtCore/QtGlobal>
#include <QtCore/QtMath>

#include "uihelper.h"

UIHelper::UIHelper(QObject *parent) : QObject(parent)
{
}

UIHelper::~UIHelper()
{
}

int UIHelper::getSafeAreaTopMargin()
{
    UIViewController * __block root_view_controller = nil;

    [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
        root_view_controller = [window rootViewController];

        *stop = (root_view_controller != nil);
    }];

    if (@available(iOS 11, *)) {
        CGSize  status_bar_size   = [[UIApplication sharedApplication] statusBarFrame].size;
        CGFloat status_bar_height = qMin(status_bar_size.width, status_bar_size.height);

        return qFloor(root_view_controller.view.safeAreaInsets.top - status_bar_height);
    } else {
        assert(0);
    }
}

int UIHelper::getSafeAreaBottomMargin()
{
    UIViewController * __block root_view_controller = nil;

    [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
        root_view_controller = [window rootViewController];

        *stop = (root_view_controller != nil);
    }];

    if (@available(iOS 11, *)) {
        return qFloor(root_view_controller.view.safeAreaInsets.bottom);
    } else {
        assert(0);
    }
}

QString UIHelper::getAppSettingsUrl()
{
    return QString::fromNSString(UIApplicationOpenSettingsURLString);
}
