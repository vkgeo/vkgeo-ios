#ifndef LOCATIONMANAGERDELEGATE_H
#define LOCATIONMANAGERDELEGATE_H

#ifdef __OBJC__

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@interface LocationManagerDelegate : UIResponder<CLLocationManagerDelegate>

- (id)init;
- (void)dealloc;
- (void)adjustDesiredAccuracy;

@end

#endif

#endif // LOCATIONMANAGERDELEGATE_H
