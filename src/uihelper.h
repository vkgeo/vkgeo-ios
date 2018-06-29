#ifndef UIHELPER_H
#define UIHELPER_H

#include <QtCore/QObject>

class UIHelper : public QObject
{
    Q_OBJECT

public:
    explicit UIHelper(QObject *parent = 0);
    virtual ~UIHelper();

    Q_INVOKABLE int getSafeAreaTopMargin();
    Q_INVOKABLE int getSafeAreaBottomMargin();
};

#endif // UIHELPER_H
