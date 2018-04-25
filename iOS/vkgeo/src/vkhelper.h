#ifndef VKHELPER_H
#define VKHELPER_H

#include <QtCore/QObject>
#include <QtCore/QString>

#ifdef __OBJC__
@class VKDelegate;
#endif

class VKAuthState : public QObject
{
    Q_OBJECT

    Q_ENUMS(AuthState)

public:
    enum AuthState {
        StateUnknown,
        StateNotAuthorized,
        StateAuthorized
    };
};

class VKHelper : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int     authState READ authState NOTIFY authStateChanged)
    Q_PROPERTY(QString photoUrl  READ photoUrl  NOTIFY photoUrlChanged)

public:
    static const QString DEFAULT_PHOTO_URL;

    explicit VKHelper(QObject *parent = 0);
    virtual ~VKHelper();

    int authState() const;
    QString photoUrl() const;

    Q_INVOKABLE void initialize();
    Q_INVOKABLE void login();
    Q_INVOKABLE void logout();

    static void setAuthState(const int &state);

signals:
    void authStateChanged(int authState);
    void photoUrlChanged(QString photoUrl);

private:
    bool             Initialized;
    int              AuthState;
    QString          PhotoUrl;
    static VKHelper *Instance;
#ifdef __OBJC__
    VKDelegate      *VKDelegateInstance;
#else
    void            *VKDelegateInstance;
#endif
};

#endif // VKHELPER_H
