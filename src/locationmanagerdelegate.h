#ifndef LOCATIONMANAGERDELEGATE_H
#define LOCATIONMANAGERDELEGATE_H

#ifdef __OBJC__

#import <CoreLocation/CLLocationManagerDelegate.h>

@interface LocationManagerDelegate : NSObject<CLLocationManagerDelegate>

- (instancetype)init;
- (void)dealloc;

@end

#endif // __OBJC__

#endif // LOCATIONMANAGERDELEGATE_H
