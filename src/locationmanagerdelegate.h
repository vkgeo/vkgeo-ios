#ifndef LOCATIONMANAGERDELEGATE_H
#define LOCATIONMANAGERDELEGATE_H

#ifdef __OBJC__

#import <CoreLocation/CLLocationManagerDelegate.h>

@interface LocationManagerDelegate : NSObject<CLLocationManagerDelegate>

- (id)init;
- (void)dealloc;

@end

#endif

#endif // LOCATIONMANAGERDELEGATE_H
