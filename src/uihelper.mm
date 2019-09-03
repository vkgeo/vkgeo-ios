#import <UIKit/UIKit.h>

#include <QtCore/QtGlobal>
#include <QtCore/QtMath>

#include "uihelper.h"

UIHelper::UIHelper(QObject *parent) : QObject(parent)
{
    DarkTheme       = false;
    ConfiguredTheme = UITheme::ThemeAuto;
}

UIHelper &UIHelper::GetInstance()
{
    static UIHelper instance;

    return instance;
}

bool UIHelper::darkTheme() const
{
    return DarkTheme;
}

int UIHelper::configuredTheme() const
{
    return ConfiguredTheme;
}

void UIHelper::setConfiguredTheme(int theme)
{
    ConfiguredTheme = theme;

    emit configuredThemeChanged(ConfiguredTheme);

    if (ConfiguredTheme == UITheme::ThemeLight) {
        DarkTheme = false;
    } else if (ConfiguredTheme == UITheme::ThemeDark) {
        DarkTheme = true;
    } else {
        DarkTheme = false;
    }

    emit darkThemeChanged(DarkTheme);
}

QString UIHelper::getAppSettingsUrl()
{
    if (@available(iOS 8, *)) {
        return QString::fromNSString(UIApplicationOpenSettingsURLString);
    } else {
        assert(0);
    }
}

void UIHelper::sendInvitation(const QString &text)
{
    UIViewController * __block root_view_controller = nil;

    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
        root_view_controller = window.rootViewController;

        *stop = (root_view_controller != nil);
    }];

    if (@available(iOS 8, *)) {
        UIActivityViewController *activity_view_controller = [[[UIActivityViewController alloc] initWithActivityItems:@[text.toNSString()] applicationActivities:nil] autorelease];

        activity_view_controller.excludedActivityTypes = @[];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            activity_view_controller.popoverPresentationController.sourceView = root_view_controller.view;
        }

        [root_view_controller presentViewController:activity_view_controller animated:YES completion:nil];
    } else {
        assert(0);
    }
}
