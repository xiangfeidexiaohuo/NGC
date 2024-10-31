#import <Preferences/Preferences.h>
#import <roothide.h>

#define GENERAL_PREFS jbroot(@"/var/mobile/Library/Preferences/com.0xkuj.notificationsgroupcountprefs.plist")

@interface PSTableCell (PrivateColourPicker)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface NGCColorPickerCell : PSTableCell <UIColorPickerViewControllerDelegate>
@property (nonatomic, retain) UILabel *headerLabel;
@property (nonatomic, retain) UIView *colorPreview;
@property (nonatomic, retain) UIColor *tintColour;
@end
