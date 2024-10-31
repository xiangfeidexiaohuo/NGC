#import <Foundation/Foundation.h>
#import "NGCRootListController.h"
#include <spawn.h>

@implementation NGCRootListController

/* load all specifiers from plist file */
- (NSMutableArray*)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
		[self applyModificationsToSpecifiers:(NSMutableArray*)_specifiers];
	}

	return (NSMutableArray*)_specifiers;
}

- (void)headerCell
{
	@autoreleasepool {
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 140)];
		int width = [[UIScreen mainScreen] bounds].size.width;
		CGRect frame = CGRectMake(0, 20, width, 60);
		CGRect botFrame = CGRectMake(0, 55, width, 60);
	
		_label = [[UILabel alloc] initWithFrame:frame];
		[_label setNumberOfLines:1];
		_label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:35];
		[_label setText:@"通知组计数"];
		[_label setBackgroundColor:[UIColor clearColor]];
		_label.textAlignment = NSTextAlignmentCenter;
		_label.alpha = 0;

		underLabel = [[UILabel alloc] initWithFrame:botFrame];
		[underLabel setNumberOfLines:4];
		underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		[underLabel setText:@"\n统计锁屏通知组内的通知！\n\n由0xkuj构建 & 🇨🇳刀刀源"];
		[underLabel setBackgroundColor:[UIColor clearColor]];
		underLabel.textColor = [UIColor grayColor];
		underLabel.textAlignment = NSTextAlignmentCenter;
		underLabel.alpha = 0;
			
		[headerView addSubview:_label];
		[headerView addSubview:underLabel];
			
		[[self table] setTableHeaderView:headerView];
		
		[NSTimer scheduledTimerWithTimeInterval:0.5
										target:self
									selector:@selector(increaseAlpha)
									userInfo:nil
										repeats:NO];	
	}
}

/* provides the animation */
- (void)increaseAlpha
{
	[UIView animateWithDuration:0.5 animations:^{
		_label.alpha = 1;
	}completion:^(BOOL finished) {
		[UIView animateWithDuration:0.5 animations:^{
			underLabel.alpha = 1;
		}completion:nil];
	}];
}	

/* what happens when the setting pane is shown */
- (void)loadView {
    [super loadView];
	[self headerCell];
}

/* read values from preferences */
- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:GENERAL_PREFS];
	id obj = [dict objectForKey:[[specifier properties] objectForKey:@"key"]];
	if(!obj)
	{
		obj = [[specifier properties] objectForKey:@"default"];
	}
	return obj;
}

/* set the value immediately when needed */
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:GENERAL_PREFS];
	if (!settings) {
		settings = [NSMutableDictionary dictionary];
	}
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:GENERAL_PREFS atomically:YES];
	
	if(specifier.cellType == PSSwitchCell)	{
		NSNumber* numValue = (NSNumber*)value;
		NSNumber* nestedEntryCount = [[specifier properties] objectForKey:@"nestedEntryCount"];
		if(nestedEntryCount)	{
			NSInteger index = [_allSpecifiers indexOfObject:specifier];
			NSMutableArray* nestedEntries = [[_allSpecifiers subarrayWithRange:NSMakeRange(index + 1, [nestedEntryCount intValue])] mutableCopy];
			//[self removeDisabledGroups:nestedEntries];

			if([numValue boolValue])  {
				[self insertContiguousSpecifiers:nestedEntries afterSpecifier:specifier animated:YES];
			}
			else  {
				[self removeContiguousSpecifiers:nestedEntries animated:YES];
			}
		}
	}
}

/* actually remove them when disabled */
- (void)removeDisabledGroups:(NSMutableArray*)specifiers;
{
	for(PSSpecifier* specifier in [specifiers reverseObjectEnumerator])
	{
		NSNumber* nestedEntryCount = [[specifier properties] objectForKey:@"nestedEntryCount"];
		if(nestedEntryCount)
		{
			BOOL enabled = [[self readPreferenceValue:specifier] boolValue];
			if(!enabled)
			{
				NSMutableArray* nestedEntries = [[_allSpecifiers subarrayWithRange:NSMakeRange([_allSpecifiers indexOfObject:specifier]+1, [nestedEntryCount intValue])] mutableCopy];

				BOOL containsNestedEntries = NO;

				for(PSSpecifier* nestedEntry in nestedEntries)	{
					NSNumber* nestedNestedEntryCount = [[nestedEntry properties] objectForKey:@"nestedEntryCount"];
					if(nestedNestedEntryCount)	{
						containsNestedEntries = YES;
						break;
					}
				}

				if(containsNestedEntries)	{
					[self removeDisabledGroups:nestedEntries];
				}

				[specifiers removeObjectsInArray:nestedEntries];
			}
		}
	}
}

/* save a copy of those specifications so we can retrieve them later */
- (void)applyModificationsToSpecifiers:(NSMutableArray*)specifiers
{
	_allSpecifiers = [specifiers copy];
	[self removeDisabledGroups:specifiers];
}


/* default settings and repsring right after. files to be deleted are specified in this function */
-(void)defaultsettings:(PSSpecifier*)specifier {
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"确认"
    									                    message:@"🇨🇳刀刀源提醒：这将把插件设置还原为默认值\n你确定吗？" 
    														preferredStyle:UIAlertControllerStyleAlert];
	/* prepare function for "yes" button */
	UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault
    		handler:^(UIAlertAction * action) {
				[[NSFileManager defaultManager] removeItemAtURL: [NSURL fileURLWithPath:GENERAL_PREFS] error: nil];
    			[self reload];
				UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
				message:@"设置已恢复为默认值\n请注销设备" 
				preferredStyle:UIAlertControllerStyleAlert];
				UIAlertAction* DoneAction =  [UIAlertAction actionWithTitle:@"注销" style:UIAlertActionStyleDefault
    			handler:^(UIAlertAction * action) {
					[self respring:nil];
				}];
				[alert addAction:DoneAction];
				[self presentViewController:alert animated:YES completion:nil];
	}];
	/* prepare function for "no" button" */
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"不" style: UIAlertActionStyleCancel handler:^(UIAlertAction * action) { return; }];
	/* actually assign those actions to the buttons */
	[alertController addAction:OKAction];
    [alertController addAction:cancelAction];
	/* present the dialog and wait for an answer */
	[self presentViewController:alertController animated:YES completion:nil];
	return;
}

- (void)respring:(id)sender {
	pid_t pid;
	const char* args[] = {"killall", "backboardd", NULL};
	posix_spawn(&pid, "/var/jb/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

/* iOS 13 deprecated these functions */
-(void)openTwitter {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://www.x.com/0xkuj"];
	[application openURL:URL options:@{} completionHandler:^(BOOL success) {return;}];
}

-(void)donationLink {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://www.paypal.me/0xkuj"];
	[application openURL:URL options:@{} completionHandler:^(BOOL success) {return;}];
}
@end
