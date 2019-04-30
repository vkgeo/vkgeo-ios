#ifndef UIHELPER_H
#define UIHELPER_H

#include <QtCore/QObject>
#include <QtCore/QString>

class UIHelper : public QObject
{
    Q_OBJECT

public:
    explicit UIHelper(QObject *parent = nullptr);

    UIHelper(const UIHelper&) = delete;
    UIHelper(UIHelper&&) noexcept = delete;

    UIHelper& operator=(const UIHelper&) = delete;
    UIHelper& operator=(UIHelper&&) noexcept = delete;

    ~UIHelper() noexcept override = default;

    Q_INVOKABLE QString getAppSettingsUrl();

    Q_INVOKABLE void sendInvitation(const QString &text);
};

#endif // UIHELPER_H
