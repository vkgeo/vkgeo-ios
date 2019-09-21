#import <UIKit/UIKit.h>

#include "uihelper.h"

@interface QIOSViewController : UIViewController
@end

@interface QIOSViewController (QIOSViewControllerVKGeoCategory)
@end

@implementation QIOSViewController (QIOSViewControllerVKGeoCategory)

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection API_AVAILABLE(ios(8))
{
    [super traitCollectionDidChange: previousTraitCollection];

    UIHelper::GetInstance().handleTraitCollectionUpdate();
}

@end
