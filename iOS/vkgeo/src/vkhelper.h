#ifndef VKHELPER_H
#define VKHELPER_H

#include <QtCore/QObject>

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

    Q_PROPERTY(int authState READ authState NOTIFY authStateChanged)

public:
    explicit VKHelper(QObject *parent = 0);
    virtual ~VKHelper();

    int authState() const;

    Q_INVOKABLE void initialize();
    Q_INVOKABLE void login();
    Q_INVOKABLE void logout();

    static void setAuthState(const int &state);

signals:
    void authStateChanged(int authState);

private:
    bool             Initialized;
    int              AuthState;
    static VKHelper *Instance;
#ifdef __OBJC__
    VKDelegate      *VKDelegateInstance;
#else
    void            *VKDelegateInstance;
#endif
};

#endif // VKHELPER_H
