#ifndef VKHELPER_H
#define VKHELPER_H

#ifdef __OBJC__
#import <VKSdkFramework/VKSdkFramework.h>
#endif

#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QVariantMap>
#include <QtCore/QQueue>
#include <QtCore/QTimer>

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
    static const int MAX_BATCH_SIZE = 25;

    static const QString DEFAULT_PHOTO_URL,
                         DATA_NOTE_TITLE;

    explicit VKHelper(QObject *parent = 0);
    virtual ~VKHelper();

    int authState() const;
    QString photoUrl() const;

    Q_INVOKABLE void initialize();
    Q_INVOKABLE void login();
    Q_INVOKABLE void logout();
    Q_INVOKABLE void reportCoordinate(qreal latitude, qreal longitude);

    static void setAuthState(const int &state);

signals:
    void authStateChanged(int authState);
    void photoUrlChanged(QString photoUrl);

private slots:
    void requestQueueTimerTimeout();

private:
    void       EnqueueRequest(QVariantMap request);
#ifdef __OBJC__
    VKRequest *ProcessRequest(QVariantMap request);
#else
    void      *ProcessRequest(QVariantMap request);
#endif
    void       ProcessNotesGetResponse(QVariantMap request, QString response);
    void       ProcessNotesAddResponse(QVariantMap request, QString response);

    bool                Initialized;
    int                 AuthState;
    QString             PhotoUrl, DataNoteId;
    QQueue<QVariantMap> RequestQueue;
    QTimer              RequestQueueTimer;
    static VKHelper    *Instance;
#ifdef __OBJC__
    VKDelegate         *VKDelegateInstance;
#else
    void               *VKDelegateInstance;
#endif
};

#endif // VKHELPER_H
