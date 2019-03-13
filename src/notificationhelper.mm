#import <UserNotifications/UNUserNotificationCenter.h>
#import <UserNotifications/UNNotificationSettings.h>
#import <UserNotifications/UNNotificationSound.h>
#import <UserNotifications/UNNotificationContent.h>
#import <UserNotifications/UNNotificationRequest.h>

#include <QtCore/QDebug>

#include "notificationhelper.h"

NotificationHelper::NotificationHelper(QObject *parent) : QObject(parent)
{
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionSound)
                                                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        Q_UNUSED(granted)

        if (error != nil) {
            qWarning() << QString::fromNSString(error.localizedDescription);
        }
    }];
}

void NotificationHelper::showNotification(const QString &id, const QString &title, const QString &body)
{
    NSString *ns_id    = id.toNSString();
    NSString *ns_title = title.toNSString();
    NSString *ns_body  = body.toNSString();

    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            UNMutableNotificationContent *content = [[[UNMutableNotificationContent alloc] init] autorelease];

            content.title = ns_title;
            content.body  = ns_body;
            content.sound = UNNotificationSound.defaultSound;

            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:ns_id content:content trigger:nil];

            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (error != nil) {
                    qWarning() << QString::fromNSString(error.localizedDescription);
                }
            }];
        }
    }];
}

void NotificationHelper::hideNotification(const QString &id)
{
    NSString *ns_id = id.toNSString();

    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[ns_id]];
        }
    }];
}
