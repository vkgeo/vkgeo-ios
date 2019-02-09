#ifndef LOCATIONMANAGERDELEGATE_H
#define LOCATIONMANAGERDELEGATE_H

#ifdef __OBJC__

#import <CoreLocation/CLLocationManagerDelegate.h>

@interface LocationManagerDelegate : NSObject<CLLocationManagerDelegate>

- (id)init;
- (void)dealloc;
- (void)adjustDesiredAccuracy;

@end

#endif

#endif // LOCATIONMANAGERDELEGATE_H
