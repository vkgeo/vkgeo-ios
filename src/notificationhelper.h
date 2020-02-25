#ifndef NOTIFICATIONHELPER_H
#define NOTIFICATIONHELPER_H

#include <QtCore/QObject>
#include <QtCore/QString>

class NotificationHelper : public QObject
{
    Q_OBJECT

private:
    explicit NotificationHelper(QObject *parent = nullptr);
    ~NotificationHelper() noexcept override = default;

public:
    NotificationHelper(const NotificationHelper &) = delete;
    NotificationHelper(NotificationHelper &&) noexcept = delete;

    NotificationHelper &operator=(const NotificationHelper &) = delete;
    NotificationHelper &operator=(NotificationHelper &&) noexcept = delete;

    static NotificationHelper &GetInstance();

    Q_INVOKABLE void showNotification(const QString &id, const QString &title, const QString &body) const;
    Q_INVOKABLE void hideNotification(const QString &id) const;
};

#endif // NOTIFICATIONHELPER_H
