#ifndef UIHELPER_H
#define UIHELPER_H

#include <QtCore/QObject>
#include <QtCore/QString>

class UIHelper : public QObject
{
    Q_OBJECT

public:
    explicit UIHelper(QObject *parent = nullptr);
    ~UIHelper() override = default;

    Q_INVOKABLE QString getAppSettingsUrl();

    Q_INVOKABLE void sendInvitation(const QString &text);
};

#endif // UIHELPER_H
