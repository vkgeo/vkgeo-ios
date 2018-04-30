#ifndef VKHELPER_H
#define VKHELPER_H

#ifdef __OBJC__
#import <VKSdkFramework/VKSdkFramework.h>
#endif

#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QQueue>
#include <QtCore/QMap>
#include <QtCore/QVariantMap>
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

    Q_PROPERTY(int     authState    READ authState    NOTIFY authStateChanged)
    Q_PROPERTY(int     friendsCount READ friendsCount NOTIFY friendsCountChanged)
    Q_PROPERTY(QString photoUrl     READ photoUrl     NOTIFY photoUrlChanged)

    Q_PROPERTY(int maxTrustedFriendsCount READ maxTrustedFriendsCount WRITE setMaxTrustedFriendsCount)

public:
    static const int DEFAULT_MAX_TRUSTED_FRIENDS_COUNT = 10,
                     MAX_BATCH_SIZE                    = 25,
                     MAX_NOTES_GET_COUNT               = 100,
                     MAX_FRIENDS_GET_COUNT             = 5000;

    static const QString DEFAULT_PHOTO_URL,
                         DATA_NOTE_TITLE,
                         TRUSTED_FRIENDS_LIST_NAME;

    explicit VKHelper(QObject *parent = 0);
    virtual ~VKHelper();

    int authState() const;
    int friendsCount() const;
    QString photoUrl() const;

    int maxTrustedFriendsCount() const;
    void setMaxTrustedFriendsCount(const int &count);

    Q_INVOKABLE void initialize();

    Q_INVOKABLE void login();
    Q_INVOKABLE void logout();

    Q_INVOKABLE void reportCoordinate(qreal latitude, qreal longitude);

    Q_INVOKABLE void updateFriends();
    Q_INVOKABLE QVariantList getFriends();

    Q_INVOKABLE void updateTrustedFriendsList(QVariantList trusted_friends_list);

    static void setAuthState(const int &state);

signals:
    void authStateChanged(int authState);
    void friendsCountChanged(int friendsCount);
    void photoUrlChanged(QString photoUrl);
    void friendsUpdated(QVariantList friendsList);

private slots:
    void requestQueueTimerTimeout();

private:
    void TrackerAddRequest(QVariantMap request);
    void TrackerDelRequest(QVariantMap request);

    bool ContextHaveActiveRequests(QString context);

    void       EnqueueRequest(QVariantMap request);
#ifdef __OBJC__
    VKRequest *ProcessRequest(QVariantMap request);
#else
    void      *ProcessRequest(QVariantMap request);
#endif

    void ProcessNotesGetResponse(QString response, QVariantMap resp_request);
    void ProcessNotesGetError(QVariantMap err_request);

    void ProcessNotesAddResponse(QString response, QVariantMap resp_request);
    void ProcessNotesAddError(QVariantMap err_request);

    void ProcessNotesEditResponse(QString response, QVariantMap resp_request);
    void ProcessNotesEditError(QVariantMap err_request);

    void ProcessFriendsGetResponse(QString response, QVariantMap resp_request);
    void ProcessFriendsGetError(QVariantMap err_request);

    void ProcessFriendsGetListsResponse(QString response, QVariantMap resp_request);
    void ProcessFriendsGetListsError(QVariantMap err_request);

    void ProcessFriendsAddListResponse(QString response, QVariantMap resp_request);
    void ProcessFriendsAddListError(QVariantMap err_request);

    void ProcessFriendsEditListResponse(QString response, QVariantMap resp_request);
    void ProcessFriendsEditListError(QVariantMap err_request);

    bool                Initialized;
    int                 AuthState, MaxTrustedFriendsCount;
    QString             PhotoUrl, DataNoteId, TrustedFriendsListId;
    QQueue<QVariantMap> RequestQueue;
    QTimer              RequestQueueTimer;
    QMap<QString, int>  RequestContextTracker;
    QVariantMap         FriendsData, FriendsDataTmp;
    static VKHelper    *Instance;
#ifdef __OBJC__
    VKDelegate         *VKDelegateInstance;
#else
    void               *VKDelegateInstance;
#endif
};

#endif // VKHELPER_H
