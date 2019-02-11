#ifndef UIHELPER_H
#define UIHELPER_H

#include <QtCore/QObject>
#include <QtCore/QString>

class UIHelper : public QObject
{
    Q_OBJECT

public:
    explicit UIHelper(QObject *parent = nullptr);
    virtual ~UIHelper();

    Q_INVOKABLE int getSafeAreaTopMargin();
    Q_INVOKABLE int getSafeAreaBottomMargin();
    Q_INVOKABLE QString getAppSettingsUrl();

    Q_INVOKABLE void sendInvitation(QString text);
};

#endif // UIHELPER_H
