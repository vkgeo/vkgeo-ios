#ifndef NOTIFICATIONHELPER_H
#define NOTIFICATIONHELPER_H

#include <QtCore/QObject>
#include <QtCore/QString>

class NotificationHelper : public QObject
{
    Q_OBJECT

public:
    explicit NotificationHelper(QObject *parent = nullptr);
    virtual ~NotificationHelper();

    Q_INVOKABLE void showNotification(QString id, QString title, QString body);
};

#endif // NOTIFICATIONHELPER_H
