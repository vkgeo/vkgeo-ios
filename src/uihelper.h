#ifndef UIHELPER_H
#define UIHELPER_H

#include <QtCore/QObject>
#include <QtCore/QString>

class UITheme : public QObject
{
    Q_OBJECT

public:
    enum Theme {
        ThemeAuto,
        ThemeLight,
        ThemeDark
    };
    Q_ENUM(Theme)
};

class UIHelper : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool darkTheme READ darkTheme NOTIFY darkThemeChanged)
    Q_PROPERTY(int  screenDpi READ screenDpi NOTIFY screenDpiChanged)

    Q_PROPERTY(int configuredTheme READ configuredTheme WRITE setConfiguredTheme NOTIFY configuredThemeChanged)

private:
    explicit UIHelper(QObject *parent = nullptr);
    ~UIHelper() noexcept override = default;

public:
    UIHelper(const UIHelper &) = delete;
    UIHelper(UIHelper &&) noexcept = delete;

    UIHelper &operator=(const UIHelper &) = delete;
    UIHelper &operator=(UIHelper &&) noexcept = delete;

    static UIHelper &GetInstance();

    bool darkTheme() const;
    int screenDpi() const;

    int configuredTheme() const;
    void setConfiguredTheme(int theme);

    Q_INVOKABLE QString getAppSettingsUrl();

    Q_INVOKABLE void sendInvitation(const QString &text);

signals:
    void darkThemeChanged(bool darkTheme);
    void screenDpiChanged(int screenDpi);
    void configuredThemeChanged(int configuredTheme);

private:
    bool DarkTheme;
    int  ConfiguredTheme;
};

#endif // UIHELPER_H
