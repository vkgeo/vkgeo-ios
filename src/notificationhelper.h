#ifndef NOTIFICATIONHELPER_H
#define NOTIFICATIONHELPER_H

#include <QtCore/QObject>
#include <QtCore/QString>

class NotificationHelper : public QObject
{
    Q_OBJECT

public:
    explicit NotificationHelper(QObject *parent = nullptr);

    NotificationHelper(const NotificationHelper&) = delete;
    NotificationHelper(const NotificationHelper&&) noexcept = delete;

    NotificationHelper& operator=(const NotificationHelper&) = delete;
    NotificationHelper& operator=(const NotificationHelper&&) noexcept = delete;

    ~NotificationHelper() noexcept override = default;

    Q_INVOKABLE void showNotification(const QString &id, const QString &title, const QString &body);
    Q_INVOKABLE void hideNotification(const QString &id);
};

#endif // NOTIFICATIONHELPER_H
