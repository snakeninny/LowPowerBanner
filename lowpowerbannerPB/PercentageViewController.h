@interface PercentageViewController : UITableViewController <UITableViewDelegate, UITextFieldDelegate> {
	NSString *levelString;

	NSString *downToneString;
	NSString *downVibrateString;
	NSString *downTitleString;
	NSString *downMessageString;
	NSString *downIconString;

	UISwitch *downVibrateSwitch;
	UITextField *downTitleField;
	UITextField *downMessageField;

	NSString *upToneString;
	NSString *upVibrateString;
	NSString *upTitleString;
	NSString *upMessageString;
	NSString *upIconString;

	UISwitch *upVibrateSwitch;
	UITextField *upTitleField;
	UITextField *upMessageField;
}
- (void)loadSettings;
- (void)saveConfig;
- (void)animateTextField:(UITextField *)textField up:(BOOL)up;

@property (nonatomic, retain) NSString *levelString;
@property (nonatomic, retain) NSString *downToneString;
@property (nonatomic, retain) NSString *downVibrateString;
@property (nonatomic, retain) NSString *downTitleString;
@property (nonatomic, retain) NSString *downMessageString;
@property (nonatomic, retain) NSString *downIconString;
@property (nonatomic, retain) NSString *upToneString;
@property (nonatomic, retain) NSString *upVibrateString;
@property (nonatomic, retain) NSString *upTitleString;
@property (nonatomic, retain) NSString *upMessageString;
@property (nonatomic, retain) NSString *upIconString;
@end
