#import "NGCBadgeView.h"

CGFloat ngcBadgeSizeLowerThan10 = 20;
CGFloat ngcBadgeSizeHigherThan10 = 30;

@interface NCNotificationShortLookView : UIView
- (BOOL)isNotificationContentViewHidden;
@end 

@interface NGCBadgeView ()
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, retain) MTMaterialView *blurView;
@property (nonatomic, copy) NSString *badgeText;
@property (nonatomic) CGRect origFrame;
@end

@implementation NGCBadgeView
- (instancetype)initWithBadgeText:(NSString *)text badgeColor:(UIColor *)badgeColor textColor:(UIColor *)textColor style:(NSUInteger)style shadowOpacity:(CGFloat)shadowOpacity {
    self = [super init];
    if (self) {
        if (style == BadgeStyleIconColors) {
            self.clipsToBounds = YES;
            self.blurView = [NSClassFromString(@"MTMaterialView") materialViewWithRecipe:6 configuration:1];
            self.blurView.weighting = 1;
            self.blurView.recipeDynamic = YES;
            self.blurView.zoomEnabled = YES;
            [self addSubview:self.blurView];

            self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.blurView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
            [self.blurView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
            [self.blurView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
            [self.blurView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
		}
        else
            self.backgroundColor = badgeColor;

        self.badgeLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.badgeLabel.textAlignment = NSTextAlignmentCenter;
        self.badgeLabel.textColor = textColor == nil ? [UIColor whiteColor] : textColor;
        self.badgeLabel.font = [UIFont boldSystemFontOfSize:13.0];
        self.badgeLabel.adjustsFontSizeToFitWidth = YES;
        self.badgeLabel.minimumScaleFactor = 0.5;
        self.badgeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.badgeLabel];
        [self setBadgeText:text];
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowRadius = 3.0;  
        self.layer.shadowOpacity = shadowOpacity;
        self.clipsToBounds = NO;  
    }
    return self;
}

- (void)layoutSubviews {    
    [super layoutSubviews];

    if (self.blurView)
        self.blurView.layer.cornerRadius = self.frame.size.height / 2;
    else
        self.layer.cornerRadius = self.frame.size.height / 2;        

    // fix ghosting badge (hopefully)
    if ([((NCNotificationShortLookView*)self.superview) isNotificationContentViewHidden]) {
        self.badgeLabel.text = @"0";
    }
}

- (void)setBadgeText:(NSString *)text {
    _badgeText = [text copy];
    self.badgeLabel.text = text;
    // Hide if text is empty or zero
    self.hidden = (text == nil || [text isEqualToString:@""] || [text isEqualToString:@"0"]);
    if ([text integerValue] > 9) {
        self.badgeLabel.font = [UIFont boldSystemFontOfSize:11.5];
    } else {
        self.badgeLabel.font = [UIFont boldSystemFontOfSize:13.0];
    }
}

- (NSString *)getBadgeText {
    return self.badgeLabel.text;
}
@end
