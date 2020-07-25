#import <UIKit/UIKit.h>

#include "uihelper.h"

@interface QIOSViewController : UIViewController
@end

@interface QIOSViewController (VKGeo)
@end

@implementation QIOSViewController (VKGeo)

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection API_AVAILABLE(ios(8))
{
    [super traitCollectionDidChange:previousTraitCollection];

    UIHelper::GetInstance().HandleTraitCollectionUpdate();
}

@end
