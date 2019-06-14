#ifndef STOREHELPER_H
#define STOREHELPER_H

#include <QtCore/QObject>

class StoreHelper : public QObject
{
    Q_OBJECT

private:
    explicit StoreHelper(QObject *parent = nullptr);
    ~StoreHelper() noexcept override = default;

public:
    StoreHelper(const StoreHelper &) = delete;
    StoreHelper(StoreHelper &&) noexcept = delete;

    StoreHelper &operator=(const StoreHelper &) = delete;
    StoreHelper &operator=(StoreHelper &&) noexcept = delete;

    static StoreHelper &GetInstance();

    Q_INVOKABLE void requestReview();
};

#endif // STOREHELPER_H
