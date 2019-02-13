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

NotificationHelper::~NotificationHelper()
{
}

void NotificationHelper::showNotification(QString id, QString title, QString body)
{
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            UNMutableNotificationContent *content = [[[UNMutableNotificationContent alloc] init] autorelease];

            content.title = title.toNSString();
            content.body  = body.toNSString();
            content.sound = UNNotificationSound.defaultSound;

            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:id.toNSString() content:content trigger:nil];

            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (error != nil) {
                    qWarning() << QString::fromNSString(error.localizedDescription);
                }
            }];
        }
    }];
}

void NotificationHelper::hideNotification(QString id)
{
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[id.toNSString()]];
        }
    }];
}
