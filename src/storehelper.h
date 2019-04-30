#ifndef STOREHELPER_H
#define STOREHELPER_H

#include <QtCore/QObject>

class StoreHelper : public QObject
{
    Q_OBJECT

public:
    explicit StoreHelper(QObject *parent = nullptr);

    StoreHelper(const StoreHelper&) = delete;
    StoreHelper(StoreHelper&&) noexcept = delete;

    StoreHelper& operator=(const StoreHelper&) = delete;
    StoreHelper& operator=(StoreHelper&&) noexcept = delete;

    ~StoreHelper() noexcept override = default;

    Q_INVOKABLE void requestReview();
};

#endif // STOREHELPER_H
