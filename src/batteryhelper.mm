#import <UIKit/UIKit.h>

#include <QtCore/QtMath>

#include "batteryhelper.h"

BatteryHelper::BatteryHelper(QObject *parent) : QObject(parent)
{
    UIDevice.currentDevice.batteryMonitoringEnabled = YES;
}

BatteryHelper &BatteryHelper::GetInstance()
{
    static BatteryHelper instance;

    return instance;
}

QString BatteryHelper::getBatteryStatus() const
{
    UIDeviceBatteryState battery_state = UIDevice.currentDevice.batteryState;

    if (battery_state == UIDeviceBatteryStateCharging ||
        battery_state == UIDeviceBatteryStateFull) {
        return QStringLiteral("CHARGING");
    } else if (battery_state == UIDeviceBatteryStateUnplugged) {
        return QStringLiteral("DISCHARGING");
    } else {
        return QStringLiteral("UNKNOWN");
    }
}

int BatteryHelper::getBatteryLevel() const
{
    auto battery_level = static_cast<qreal>(UIDevice.currentDevice.batteryLevel);

    if (battery_level > 0.0) {
        return qFloor(battery_level * 100);
    } else {
        return 0;
    }
}
