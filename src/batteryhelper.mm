#import <UIKit/UIDevice.h>

#include <QtCore/QtMath>

#include "batteryhelper.h"

BatteryHelper::BatteryHelper(QObject *parent) : QObject(parent)
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
}

BatteryHelper::~BatteryHelper()
{
}

QString BatteryHelper::getBatteryStatus()
{
    UIDeviceBatteryState battery_state = [[UIDevice currentDevice] batteryState];

    if (battery_state == UIDeviceBatteryStateCharging ||
        battery_state == UIDeviceBatteryStateFull) {
        return "CHARGING";
    } else if (battery_state == UIDeviceBatteryStateUnplugged) {
        return "DISCHARGING";
    } else {
        return "UNKNOWN";
    }
}

int BatteryHelper::getBatteryLevel()
{
    return qFloor(static_cast<qreal>([[UIDevice currentDevice] batteryLevel]));
}
