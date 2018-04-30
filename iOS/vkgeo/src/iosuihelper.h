#ifndef IOSUIHELPER_H
#define IOSUIHELPER_H

#include <QtCore/QObject>

class IOSUIHelper : public QObject
{
    Q_OBJECT

public:
    explicit IOSUIHelper(QObject *parent = 0);
    virtual ~IOSUIHelper();

    Q_INVOKABLE int safeAreaTopMargin();
    Q_INVOKABLE int safeAreaBottomMargin();
};

#endif // IOSUIHELPER_H
