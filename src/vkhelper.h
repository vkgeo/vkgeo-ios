#ifndef VKHELPER_H
#define VKHELPER_H

#include <QtCore/QtGlobal>
#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QQueue>
#include <QtCore/QVariantList>
#include <QtCore/QMap>
#include <QtCore/QVariantMap>
#include <QtCore/QTimer>

#ifdef __OBJC__
@class VKRequest;
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

    Q_PROPERTY(bool   locationValid      READ locationValid)
    Q_PROPERTY(qint64 locationUpdateTime READ locationUpdateTime)
    Q_PROPERTY(qreal  locationLatitude   READ locationLatitude)
    Q_PROPERTY(qreal  locationLongitude  READ locationLongitude)

    Q_PROPERTY(int     authState    READ authState    NOTIFY authStateChanged)
    Q_PROPERTY(int     friendsCount READ friendsCount NOTIFY friendsCountChanged)
    Q_PROPERTY(QString userId       READ userId       NOTIFY userIdChanged)
    Q_PROPERTY(QString firstName    READ firstName    NOTIFY firstNameChanged)
    Q_PROPERTY(QString lastName     READ lastName     NOTIFY lastNameChanged)
    Q_PROPERTY(QString photoUrl     READ photoUrl     NOTIFY photoUrlChanged)
    Q_PROPERTY(QString bigPhotoUrl  READ bigPhotoUrl  NOTIFY bigPhotoUrlChanged)

    Q_PROPERTY(int maxTrustedFriendsCount READ maxTrustedFriendsCount WRITE setMaxTrustedFriendsCount NOTIFY maxTrustedFriendsCountChanged)
    Q_PROPERTY(int maxTrackedFriendsCount READ maxTrackedFriendsCount WRITE setMaxTrackedFriendsCount NOTIFY maxTrackedFriendsCountChanged)

public:
    static const int DEFAULT_MAX_TRUSTED_FRIENDS_COUNT    = 5,
                     DEFAULT_MAX_TRACKED_FRIENDS_COUNT    = 5,
                     MAX_SEND_DATA_TRIES_COUNT            = 5,
                     REQUEST_QUEUE_TIMER_INTERVAL         = 1000,
                     SEND_DATA_ON_UPDATE_TIMER_INTERVAL   = 100,
                     SEND_DATA_TIMER_INTERVAL             = 60000,
                     SEND_DATA_INTERVAL                   = 300,
                     UPDATE_TRACKED_FRIENDS_DATA_INTERVAL = 60,
                     MAX_BATCH_SIZE                       = 25,
                     MAX_NOTES_GET_COUNT                  = 100,
                     MAX_FRIENDS_GET_COUNT                = 500;

    static const QString DEFAULT_PHOTO_URL,
                         DATA_NOTE_TITLE,
                         TRUSTED_FRIENDS_LIST_NAME,
                         TRACKED_FRIENDS_LIST_NAME;

    explicit VKHelper(QObject *parent = nullptr);
    virtual ~VKHelper();

    bool locationValid() const;
    qint64 locationUpdateTime() const;
    qreal locationLatitude() const;
    qreal locationLongitude() const;

    int authState() const;
    int friendsCount() const;
    QString userId() const;
    QString firstName() const;
    QString lastName() const;
    QString photoUrl() const;
    QString bigPhotoUrl() const;

    int maxTrustedFriendsCount() const;
    void setMaxTrustedFriendsCount(int count);

    int maxTrackedFriendsCount() const;
    void setMaxTrackedFriendsCount(int count);

    Q_INVOKABLE void cleanup();

    Q_INVOKABLE void login();
    Q_INVOKABLE void logout();

    Q_INVOKABLE void updateLocation(qreal latitude, qreal longitude);
    Q_INVOKABLE void updateBatteryStatus(QString status, int level);
    Q_INVOKABLE void sendData();

    Q_INVOKABLE void updateFriends();
    Q_INVOKABLE QVariantMap getFriends();
    Q_INVOKABLE QVariantList getFriendsList();

    Q_INVOKABLE void updateTrustedFriendsList(QVariantList trusted_friends_list);
    Q_INVOKABLE void updateTrackedFriendsList(QVariantList tracked_friends_list);

    Q_INVOKABLE void updateTrackedFriendsData(bool expedited);

    Q_INVOKABLE void sendMessage(QString user_id, QString message);
    Q_INVOKABLE void sendInvitation(QString user_id, QString text);

    Q_INVOKABLE void joinGroup(QString group_id);

    static void setAuthState(int state);

private slots:
    void requestQueueTimerTimeout();
    void sendDataOnUpdateTimerTimeout();
    void sendDataTimerTimeout();

signals:
    void authStateChanged(int authState);
    void friendsCountChanged(int friendsCount);
    void userIdChanged(QString userId);
    void firstNameChanged(QString firstName);
    void lastNameChanged(QString lastName);
    void photoUrlChanged(QString photoUrl);
    void bigPhotoUrlChanged(QString bigPhotoUrl);
    void maxTrustedFriendsCountChanged(int maxTrustedFriendsCount);
    void maxTrackedFriendsCountChanged(int maxTrackedFriendsCount);
    void locationUpdated();
    void batteryStatusUpdated();
    void dataSent();
    void friendsUpdated();
    void trackedFriendDataUpdated(QString id, QVariantMap data);

private:
    void SendData(bool expedited);

    void ContextTrackerAddRequest(QVariantMap request);
    void ContextTrackerDelRequest(QVariantMap request);

    bool ContextHasActiveRequests(QString context);

    void EnqueueRequest(QVariantMap request);

    void ProcessResponse(QString response, QVariantMap resp_request);
    void ProcessError(QString error_message, QVariantMap err_request);

    void ProcessNotesGetResponse(QString response, QVariantMap resp_request);
    void ProcessNotesGetError(QVariantMap err_request);

    void ProcessNotesAddResponse(QString response, QVariantMap resp_request);
    void ProcessNotesAddError(QVariantMap err_request);

    void ProcessNotesDeleteResponse(QString response, QVariantMap resp_request);
    void ProcessNotesDeleteError(QVariantMap err_request);

    void ProcessFriendsGetResponse(QString response, QVariantMap resp_request);
    void ProcessFriendsGetError(QVariantMap err_request);

    void ProcessFriendsGetListsResponse(QString response, QVariantMap resp_request);
    void ProcessFriendsGetListsError(QVariantMap err_request);

    void ProcessFriendsAddListResponse(QString response, QVariantMap resp_request);
    void ProcessFriendsAddListError(QVariantMap err_request);

    void ProcessFriendsEditListResponse(QString response, QVariantMap resp_request);
    void ProcessFriendsEditListError(QVariantMap err_request);

    void ProcessMessagesSendResponse(QString response, QVariantMap resp_request);
    void ProcessMessagesSendError(QVariantMap err_request);

    void ProcessAppsSendRequestResponse(QString response, QVariantMap resp_request);
    void ProcessAppsSendRequestError(QVariantMap err_request);

    void ProcessGroupsJoinResponse(QString response, QVariantMap resp_request);
    void ProcessGroupsJoinError(QVariantMap err_request);

    enum DataState {
        DataNotUpdated,
        DataUpdated,
        DataUpdatedAndSent
    };

    int                          CurrentDataState, AuthState, MaxTrustedFriendsCount,
                                 MaxTrackedFriendsCount, SendDataTryNumber;
    qint64                       LastSendDataTime, LastUpdateTrackedFriendsDataTime,
                                 NextRequestQueueTimerTimeout;
    QString                      UserId, FirstName, LastName, PhotoUrl, BigPhotoUrl,
                                 TrustedFriendsListId, TrackedFriendsListId;
    QTimer                       RequestQueueTimer, SendDataOnUpdateTimer, SendDataTimer;
    QQueue<QVariantMap>          RequestQueue;
    QMap<QString, int>           ContextTracker;
#ifdef __OBJC__
    QMap<VKRequest *, bool>      VKRequestTracker;
#else
    QMap<void *, bool>           VKRequestTracker;
#endif
    QVariantMap                  CurrentData, FriendsData, FriendsDataTmp;
    static VKHelper             *Instance;
#ifdef __OBJC__
    VKDelegate                  *VKDelegateInstance;
#else
    void                        *VKDelegateInstance;
#endif
};

#endif // VKHELPER_H
