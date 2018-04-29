#include <QtCore/QDateTime>
#include <QtCore/QJsonObject>
#include <QtCore/QJsonArray>
#include <QtCore/QJsonDocument>
#include <QtCore/QDebug>

#include "vkhelper.h"

const QString VKHelper::DEFAULT_PHOTO_URL("https://vk.com/images/camera_50.png");
const QString VKHelper::DATA_NOTE_TITLE  ("VKGeo Data");

static NSArray *AUTH_SCOPE = @[@"friends", @"notes"];

VKHelper *VKHelper::Instance = NULL;

@interface VKDelegate : NSObject<VKSdkDelegate, VKSdkUIDelegate>

- (id)init;
- (void)dealloc;

@end

@implementation VKDelegate

- (id)init
{
    self = [super init];

    if (self) {
        [[VKSdk instance] registerDelegate:self];
        [[VKSdk instance] setUiDelegate:self];

        [VKSdk wakeUpSession:AUTH_SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
            if (error != nil) {
                qWarning() << QString::fromNSString([error localizedDescription]);

                VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
            } else if (state == VKAuthorizationAuthorized) {
                VKHelper::setAuthState(VKAuthState::StateAuthorized);
            } else {
                VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
            }
        }];
    }

    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result
{
    if (result.error != nil) {
        qWarning() << QString::fromNSString([result.error localizedDescription]);

        VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
    } else if (result.token != nil) {
        VKHelper::setAuthState(VKAuthState::StateAuthorized);
    } else {
        VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
    }
}

- (void)vkSdkUserAuthorizationFailed
{
    VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
}

- (void)vkSdkAuthorizationStateUpdatedWithResult:(VKAuthorizationResult *)result
{
    if (result.error != nil) {
        qWarning() << QString::fromNSString([result.error localizedDescription]);

        VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
    } else if (result.token != nil) {
        VKHelper::setAuthState(VKAuthState::StateAuthorized);
    } else {
        VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
    }
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken
{
    Q_UNUSED(expiredToken)

    VKHelper::setAuthState(VKAuthState::StateNotAuthorized);
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller
{
    UIViewController * __block root_view_controller = nil;

    [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
        root_view_controller = [window rootViewController];

        *stop = (root_view_controller != nil);
    }];

    if (root_view_controller != nil) {
        [root_view_controller presentViewController:controller animated:YES completion:nil];
    }
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError
{
    UIViewController * __block root_view_controller = nil;

    [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
        root_view_controller = [window rootViewController];

        *stop = (root_view_controller != nil);
    }];

    if (root_view_controller != nil) {
        VKCaptchaViewController *captcha_view_controller = [VKCaptchaViewController captchaControllerWithError:captchaError];

        [captcha_view_controller presentIn:root_view_controller];
    }
}

@end

bool compareFriends(const QVariant &friend_1, const QVariant &friend_2) {
    bool friend_1_online = friend_1.toMap().contains("online") ? (friend_1.toMap())["online"].toBool() : false;
    bool friend_2_online = friend_2.toMap().contains("online") ? (friend_2.toMap())["online"].toBool() : false;

    QString friend_1_name = friend_1.toMap().contains("firstName") &&
                            friend_1.toMap().contains("lastName") ?
                                QString("%1 %2").arg((friend_1.toMap())["firstName"].toString())
                                                .arg((friend_1.toMap())["lastName"].toString()) :
                                "";
    QString friend_2_name = friend_2.toMap().contains("firstName") &&
                            friend_2.toMap().contains("lastName") ?
                                QString("%1 %2").arg((friend_2.toMap())["firstName"].toString())
                                                .arg((friend_2.toMap())["lastName"].toString()) :
                                "";

    QString friend_1_note_id = friend_1.toMap().contains("dataNoteId") ?
                                   (friend_1.toMap())["dataNoteId"].toString() : "";
    QString friend_2_note_id = friend_2.toMap().contains("dataNoteId") ?
                                   (friend_2.toMap())["dataNoteId"].toString() : "";

    if (friend_1_note_id.isEmpty() == friend_2_note_id.isEmpty()) {
        if (friend_1_online == friend_2_online) {
            return friend_1_name < friend_2_name;
        } else if (friend_1_online) {
            return true;
        } else {
            return false;
        }
    } else if (!friend_1_note_id.isEmpty()) {
        return true;
    } else {
        return false;
    }
}

VKHelper::VKHelper(QObject *parent) : QObject(parent)
{
    Initialized        = false;
    AuthState          = VKAuthState::StateUnknown;
    PhotoUrl           = DEFAULT_PHOTO_URL;
    DataNoteId         = "";
    Instance           = this;
    VKDelegateInstance = NULL;

    connect(&RequestQueueTimer, SIGNAL(timeout()), this, SLOT(requestQueueTimerTimeout()));

    RequestQueueTimer.setInterval(1000);
    RequestQueueTimer.start();
}

VKHelper::~VKHelper()
{
    if (Initialized) {
        [VKDelegateInstance release];
    }
}

int VKHelper::authState() const
{
    return AuthState;
}

QString VKHelper::photoUrl() const
{
    return PhotoUrl;
}

void VKHelper::initialize()
{
    if (!Initialized) {
        VKDelegateInstance = [[VKDelegate alloc] init];

        Initialized = true;
    }
}

void VKHelper::login()
{
    if (Initialized) {
        [VKSdk authorize:AUTH_SCOPE];
    }
}

void VKHelper::logout()
{
    if (Initialized) {
        [VKSdk forceLogout];

        setAuthState(VKAuthState::StateNotAuthorized);
    }
}

void VKHelper::reportCoordinate(qreal latitude, qreal longitude)
{
    if (Initialized && !ContextHaveActiveRequests("reportCoordinate")) {
        QVariantMap request, user_data, parameters;

        user_data["update_time"] = QDateTime::currentSecsSinceEpoch();
        user_data["latitude"]    = latitude;
        user_data["longitude"]   = longitude;

        QString user_data_string = QString::fromUtf8(QJsonDocument::fromVariant(user_data).toJson(QJsonDocument::Compact));

        if (DataNoteId == "") {
            parameters["count"] = MAX_NOTES_GET_COUNT;

            request["method"]     = "notes.get";
            request["context"]    = "reportCoordinate";
            request["user_data"]  = user_data_string;
            request["parameters"] = parameters;
        } else {
            parameters["note_id"]         = DataNoteId.toInt();
            parameters["title"]           = DATA_NOTE_TITLE;
            parameters["text"]            = user_data_string;
            parameters["privacy_view"]    = "friends";
            parameters["privacy_comment"] = "nobody";

            request["method"]     = "notes.edit";
            request["context"]    = "reportCoordinate";
            request["parameters"] = parameters;
        }

        EnqueueRequest(request);
    }
}

void VKHelper::updateFriends()
{
    if (Initialized && !ContextHaveActiveRequests("updateFriends")) {
        QVariantMap request, parameters;

        FriendsData.clear();

        parameters["count"]  = MAX_FRIENDS_GET_COUNT;
        parameters["fields"] = "photo_100,photo_200_orig,online,last_seen,status";

        request["method"]     = "friends.get";
        request["context"]    = "updateFriends";
        request["parameters"] = parameters;

        EnqueueRequest(request);
    }
}

void VKHelper::setAuthState(const int &state)
{
    Instance->AuthState = state;

    emit Instance->authStateChanged(Instance->AuthState);

    if (Instance->AuthState == VKAuthState::StateAuthorized) {
        VKAccessToken *token = [VKSdk accessToken];

        if (token != nil && token.localUser != nil && token.localUser.photo_50 != nil) {
            Instance->PhotoUrl = QString::fromNSString(token.localUser.photo_50);
        } else {
            Instance->PhotoUrl = DEFAULT_PHOTO_URL;
        }
    } else {
        Instance->PhotoUrl = DEFAULT_PHOTO_URL;
    }

    emit Instance->photoUrlChanged(Instance->PhotoUrl);
}

void VKHelper::requestQueueTimerTimeout()
{
    if (!RequestQueue.isEmpty()) {
        NSMutableArray *vk_request_array = [NSMutableArray arrayWithCapacity:MAX_BATCH_SIZE];

        for (int i = 0; i < MAX_BATCH_SIZE && !RequestQueue.isEmpty(); i++) {
            QVariantMap request = RequestQueue.dequeue();

            TrackerDelRequest(request);

            VKRequest *vk_request = ProcessRequest(request);

            if (vk_request != nil) {
                [vk_request_array addObject:vk_request];
            }
        }

        if (vk_request_array.count > 0) {
            VKBatchRequest *vk_batch_request = [[[VKBatchRequest alloc] initWithRequestsArray:vk_request_array] autorelease];

            [vk_batch_request executeWithResultBlock:^(NSArray *responses) {
                Q_UNUSED(responses)
            } errorBlock:^(NSError *error) {
                Q_UNUSED(error)
            }];
        }
    }
}

void VKHelper::TrackerAddRequest(QVariantMap request)
{
    if (request.contains("context")) {
        QString context = request["context"].toString();

        if (RequestContextTracker.contains(context)) {
            RequestContextTracker[context]++;
        } else {
            RequestContextTracker[context] = 1;
        }
    } else {
        qWarning() << "TrackerAddRequest() : request have no context";
    }
}

void VKHelper::TrackerDelRequest(QVariantMap request)
{
    if (request.contains("context")) {
        QString context = request["context"].toString();

        if (RequestContextTracker.contains(context)) {
            if (RequestContextTracker[context] > 0) {
                RequestContextTracker[context]--;
            } else {
                qWarning() << QString("TrackerDelRequest() : negative tracker value for context: %1").arg(context);
            }
        } else {
            qWarning() << QString("TrackerDelRequest() : no tracker value for context: %1").arg(context);
        }
    } else {
        qWarning() << "TrackerDelRequest() : request have no context";
    }
}

bool VKHelper::ContextHaveActiveRequests(QString context)
{
    if (RequestContextTracker.contains(context) && RequestContextTracker[context] > 0) {
        return true;
    } else {
        return false;
    }
}

void VKHelper::EnqueueRequest(QVariantMap request)
{
    RequestQueue.enqueue(request);

    TrackerAddRequest(request);

    if (!RequestQueueTimer.isActive()) {
        RequestQueueTimer.start();
    }
}

VKRequest *VKHelper::ProcessRequest(QVariantMap request)
{
    if (request.contains("method") && request.contains("context")) {
        NSMutableDictionary *vk_parameters = nil;

        if (request.contains("parameters")) {
            QVariantMap parameters = request["parameters"].toMap();

            vk_parameters = [NSMutableDictionary dictionaryWithCapacity:parameters.size()];

            foreach (QString key, parameters.keys()) {
                vk_parameters[key.toNSString()] = parameters[key].toString().toNSString();
            }
        } else {
            vk_parameters = [NSMutableDictionary dictionaryWithCapacity:0];
        }

        if (request["method"].toString() == "notes.get") {
            VKRequest *vk_request = [VKRequest requestWithMethod:request["method"].toString().toNSString() parameters:vk_parameters];

            vk_request.completeBlock = ^(VKResponse *response) {
                TrackerDelRequest(request);

                ProcessNotesGetResponse(QString::fromNSString(response.responseString), request);
            };
            vk_request.errorBlock = ^(NSError *error) {
                Q_UNUSED(error)

                qWarning() << QString("ProcessRequest() : %1 request failed").arg(QString::fromNSString(vk_request.methodName));

                TrackerDelRequest(request);

                ProcessNotesGetError(request);
            };

            TrackerAddRequest(request);

            return vk_request;
        } else if (request["method"].toString() == "notes.add") {
            VKRequest *vk_request = [VKRequest requestWithMethod:request["method"].toString().toNSString() parameters:vk_parameters];

            vk_request.completeBlock = ^(VKResponse *response) {
                TrackerDelRequest(request);

                ProcessNotesAddResponse(QString::fromNSString(response.responseString), request);
            };
            vk_request.errorBlock = ^(NSError *error) {
                Q_UNUSED(error)

                qWarning() << QString("ProcessRequest() : %1 request failed").arg(QString::fromNSString(vk_request.methodName));

                TrackerDelRequest(request);

                ProcessNotesAddError(request);
            };

            TrackerAddRequest(request);

            return vk_request;
        } else if (request["method"].toString() == "notes.edit") {
            VKRequest *vk_request = [VKRequest requestWithMethod:request["method"].toString().toNSString() parameters:vk_parameters];

            vk_request.completeBlock = ^(VKResponse *response) {
                TrackerDelRequest(request);

                ProcessNotesEditResponse(QString::fromNSString(response.responseString), request);
            };
            vk_request.errorBlock = ^(NSError *error) {
                Q_UNUSED(error)

                qWarning() << QString("ProcessRequest() : %1 request failed").arg(QString::fromNSString(vk_request.methodName));

                TrackerDelRequest(request);

                ProcessNotesEditError(request);
            };

            TrackerAddRequest(request);

            return vk_request;
        } else if (request["method"].toString() == "friends.get") {
            VKRequest *vk_request = [VKRequest requestWithMethod:request["method"].toString().toNSString() parameters:vk_parameters];

            vk_request.completeBlock = ^(VKResponse *response) {
                TrackerDelRequest(request);

                ProcessFriendsGetResponse(QString::fromNSString(response.responseString), request);
            };
            vk_request.errorBlock = ^(NSError *error) {
                Q_UNUSED(error)

                qWarning() << QString("ProcessRequest() : %1 request failed").arg(QString::fromNSString(vk_request.methodName));

                TrackerDelRequest(request);

                ProcessFriendsGetError(request);
            };

            TrackerAddRequest(request);

            return vk_request;
        } else {
            qWarning() << QString("ProcessRequest() : unknown request method: %1").arg(request["method"].toString());

            return nil;
        }
    } else {
        qWarning() << "ProcessRequest() : invalid request";

        return nil;
    }
}

void VKHelper::ProcessNotesGetResponse(QString response, QVariantMap resp_request)
{
    if (resp_request["context"].toString() == "reportCoordinate") {
        QJsonDocument json_document = QJsonDocument::fromJson(response.toUtf8());

        if (!json_document.isNull() && json_document.object().contains("response")) {
            QJsonObject json_response = json_document.object().value("response").toObject();

            if (json_response.contains("count") && json_response.contains("items")) {
                QString data_note_id;

                int offset      = 0;
                int notes_count = json_response.value("count").toInt();

                if (resp_request.contains("parameters") && resp_request["parameters"].toMap().contains("offset")) {
                    offset = (resp_request["parameters"].toMap())["offset"].toInt();
                }

                QJsonArray json_items = json_response.value("items").toArray();

                for (int i = 0; i < json_items.count(); i++) {
                    QJsonObject json_note = json_items.at(i).toObject();

                    if (json_note.contains("id") && json_note.contains("title")) {
                        if (json_note.value("title") == DATA_NOTE_TITLE) {
                            data_note_id = QString::number(json_note.value("id").toInt());

                            if (data_note_id != "") {
                                break;
                            }
                        }
                    }
                }

                if (resp_request.contains("user_data")) {
                    QVariantMap request, parameters;

                    if (data_note_id != "") {
                        DataNoteId = data_note_id;

                        parameters["note_id"]         = DataNoteId.toInt();
                        parameters["title"]           = DATA_NOTE_TITLE;
                        parameters["text"]            = resp_request["user_data"].toString();
                        parameters["privacy_view"]    = "friends";
                        parameters["privacy_comment"] = "nobody";

                        request["method"]     = "notes.edit";
                        request["context"]    = resp_request["context"].toString();
                        request["parameters"] = parameters;
                    } else if (offset + json_items.count() < notes_count) {
                        parameters["count"]  = MAX_NOTES_GET_COUNT;
                        parameters["offset"] = offset + json_items.count();

                        request["method"]     = "notes.get";
                        request["context"]    = resp_request["context"].toString();
                        request["user_data"]  = resp_request["user_data"].toString();
                        request["parameters"] = parameters;
                    } else {
                        parameters["title"]           = DATA_NOTE_TITLE;
                        parameters["text"]            = resp_request["user_data"].toString();
                        parameters["privacy_view"]    = "friends";
                        parameters["privacy_comment"] = "nobody";

                        request["method"]     = "notes.add";
                        request["context"]    = resp_request["context"].toString();
                        request["parameters"] = parameters;
                    }

                    EnqueueRequest(request);
                } else {
                    qWarning() << "ProcessNotesGetResponse() : invalid request";
                }
            } else {
                qWarning() << "ProcessNotesGetResponse() : invalid response";
            }
        } else {
            qWarning() << "ProcessNotesGetResponse() : invalid json";
        }
    } else if (resp_request["context"].toString() == "updateFriends") {
        QJsonDocument json_document = QJsonDocument::fromJson(response.toUtf8());

        if (!json_document.isNull() && json_document.object().contains("response")) {
            QJsonObject json_response = json_document.object().value("response").toObject();

            if (json_response.contains("count") && json_response.contains("items")) {
                QString data_note_id;

                int offset      = 0;
                int notes_count = json_response.value("count").toInt();

                if (resp_request.contains("parameters") && resp_request["parameters"].toMap().contains("offset")) {
                    offset = (resp_request["parameters"].toMap())["offset"].toInt();
                }

                QJsonArray json_items = json_response.value("items").toArray();

                for (int i = 0; i < json_items.count(); i++) {
                    QJsonObject json_note = json_items.at(i).toObject();

                    if (json_note.contains("id") && json_note.contains("title")) {
                        if (json_note.value("title") == DATA_NOTE_TITLE) {
                            data_note_id = QString::number(json_note.value("id").toInt());

                            if (data_note_id != "") {
                                break;
                            }
                        }
                    }
                }

                if (resp_request.contains("user_id")) {
                    if (data_note_id != "") {
                        QVariantMap frnd = FriendsData[resp_request["user_id"].toString()].toMap();

                        frnd["dataNoteId"] = data_note_id;

                        FriendsData[resp_request["user_id"].toString()] = frnd;

                        QVariantList friends_list = FriendsData.values();

                        std::sort(friends_list.begin(), friends_list.end(), compareFriends);

                        emit friendsUpdated(friends_list);
                    } else if (offset + json_items.count() < notes_count) {
                        QVariantMap request, parameters;

                        parameters["count"]   = MAX_NOTES_GET_COUNT;
                        parameters["offset"]  = offset + json_items.count();
                        parameters["user_id"] = resp_request["user_id"].toString();

                        request["method"]     = "notes.get";
                        request["context"]    = resp_request["context"].toString();
                        request["user_id"]    = resp_request["user_id"].toString();
                        request["parameters"] = parameters;

                        EnqueueRequest(request);
                    }
                } else {
                    qWarning() << "ProcessNotesGetResponse() : invalid request";
                }
            } else {
                qWarning() << "ProcessNotesGetResponse() : invalid response";
            }
        } else {
            qWarning() << "ProcessNotesGetResponse() : invalid json";
        }
    }
}

void VKHelper::ProcessNotesGetError(QVariantMap err_request)
{
    Q_UNUSED(err_request)
}

void VKHelper::ProcessNotesAddResponse(QString response, QVariantMap resp_request)
{
    if (resp_request["context"].toString() == "reportCoordinate") {
        QJsonDocument json_document = QJsonDocument::fromJson(response.toUtf8());

        if (!json_document.isNull() && json_document.object().contains("response")) {
            DataNoteId = QString::number(json_document.object().value("response").toInt());
        } else {
            qWarning() << "ProcessNotesGetResponse() : invalid json";
        }
    }
}

void VKHelper::ProcessNotesAddError(QVariantMap err_request)
{
    Q_UNUSED(err_request)
}

void VKHelper::ProcessNotesEditResponse(QString response, QVariantMap resp_request)
{
    Q_UNUSED(response)
    Q_UNUSED(resp_request)
}

void VKHelper::ProcessNotesEditError(QVariantMap err_request)
{
    if (err_request["context"].toString() == "reportCoordinate") {
        DataNoteId = "";
    }
}

void VKHelper::ProcessFriendsGetResponse(QString response, QVariantMap resp_request)
{
    if (resp_request["context"].toString() == "updateFriends") {
        QJsonDocument json_document = QJsonDocument::fromJson(response.toUtf8());

        if (!json_document.isNull() && json_document.object().contains("response")) {
            QJsonObject json_response = json_document.object().value("response").toObject();

            if (json_response.contains("count") && json_response.contains("items")) {
                int offset        = 0;
                int friends_count = json_response.value("count").toInt();

                if (resp_request.contains("parameters") && resp_request["parameters"].toMap().contains("offset")) {
                    offset = (resp_request["parameters"].toMap())["offset"].toInt();
                }

                QJsonArray json_items = json_response.value("items").toArray();

                for (int i = 0; i < json_items.count(); i++) {
                    QJsonObject json_friend = json_items.at(i).toObject();

                    if (json_friend.contains("id")) {
                        if (!json_friend.contains("deactivated")) {
                            QVariantMap frnd;

                            frnd["id"]         = QString::number(json_friend.value("id").toInt());
                            frnd["dataNoteId"] = "";

                            if (json_friend.contains("first_name")) {
                                frnd["firstName"] = json_friend.value("first_name").toString();
                            } else {
                                frnd["firstName"] = "";
                            }
                            if (json_friend.contains("last_name")) {
                                frnd["lastName"] = json_friend.value("last_name").toString();
                            } else {
                                frnd["lastName"] = "";
                            }
                            if (json_friend.contains("photo_100")) {
                                frnd["photoUrl"] = json_friend.value("photo_100").toString();
                            } else {
                                frnd["photoUrl"] = DEFAULT_PHOTO_URL;
                            }
                            if (json_friend.contains("photo_200_orig")) {
                                frnd["bigPhotoUrl"] = json_friend.value("photo_200_orig").toString();
                            } else {
                                frnd["bigPhotoUrl"] = DEFAULT_PHOTO_URL;
                            }
                            if (json_friend.contains("online")) {
                                frnd["online"] = json_friend.value("online").toInt() ? true : false;
                            } else {
                                frnd["online"] = false;
                            }
                            if (json_friend.contains("status")) {
                                frnd["status"] = json_friend.value("status").toString();
                            } else {
                                frnd["status"] = "";
                            }
                            if (json_friend.contains("last_seen")) {
                                QJsonObject json_last_seen = json_friend.value("last_seen").toObject();

                                if (json_last_seen.contains("time")) {
                                    frnd["lastSeenTime"] = QString::number(json_last_seen["time"].toInt());
                                } else {
                                    frnd["lastSeenTime"] = "";
                                }
                            } else {
                                frnd["lastSeenTime"] = "";
                            }

                            FriendsData[frnd["id"].toString()] = frnd;
                        }
                    } else {
                        qWarning() << "ProcessFriendsGetResponse() : invalid entry";
                    }
                }

                if (offset + json_items.count() < friends_count) {
                    QVariantMap request, parameters;

                    parameters["count"]  = MAX_FRIENDS_GET_COUNT;
                    parameters["offset"] = offset + json_items.count();
                    parameters["fields"] = "photo_100,photo_200_orig,online,last_seen,status";

                    request["method"]     = "friends.get";
                    request["context"]    = resp_request["context"].toString();
                    request["parameters"] = parameters;

                    EnqueueRequest(request);
                } else {
                    QVariantList friends_list = FriendsData.values();

                    std::sort(friends_list.begin(), friends_list.end(), compareFriends);

                    emit friendsUpdated(friends_list);

                    foreach (QString key, FriendsData.keys()) {
                        QVariantMap request, parameters;

                        parameters["count"]   = MAX_NOTES_GET_COUNT;
                        parameters["user_id"] = key;

                        request["method"]     = "notes.get";
                        request["context"]    = resp_request["context"].toString();
                        request["user_id"]    = key;
                        request["parameters"] = parameters;

                        EnqueueRequest(request);
                    }
                }
            } else {
                qWarning() << "ProcessFriendsGetResponse() : invalid response";
            }
        } else {
            qWarning() << "ProcessFriendsGetResponse() : invalid json";
        }
    }
}

void VKHelper::ProcessFriendsGetError(QVariantMap err_request)
{
    Q_UNUSED(err_request)
}
