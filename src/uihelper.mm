#import <UIKit/UIWindow.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIActivityViewController.h>
#import <UIKit/UIPopoverPresentationController.h>

#include <QtCore/QtGlobal>
#include <QtCore/QtMath>

#include "uihelper.h"

UIHelper::UIHelper(QObject *parent) : QObject(parent)
{
}

UIHelper::~UIHelper()
{
}

QString UIHelper::getAppSettingsUrl()
{
    return QString::fromNSString(UIApplicationOpenSettingsURLString);
}

void UIHelper::sendInvitation(QString text)
{
    UIViewController * __block root_view_controller = nil;

    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
        root_view_controller = window.rootViewController;

        *stop = (root_view_controller != nil);
    }];

    UIActivityViewController *activity_view_controller = [[[UIActivityViewController alloc] initWithActivityItems:@[text.toNSString()] applicationActivities:nil] autorelease];

    activity_view_controller.excludedActivityTypes = @[];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activity_view_controller.popoverPresentationController.sourceView = root_view_controller.view;
    }

    [root_view_controller presentViewController:activity_view_controller animated:YES completion:nil];
}
