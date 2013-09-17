@interface RingtoneViewController : UITableViewController {
	NSString *levelString;
	NSString *typeString;
	NSString *toneString;
	NSMutableArray *ringtonesArray;
}
- (void)loadAllRingtones;
- (void)saveConfig;

@property (nonatomic, retain) NSString *levelString;
@property (nonatomic, retain) NSString *typeString;
@property (nonatomic, retain) NSString *toneString;
@property (nonatomic, retain) NSMutableArray *ringtonesArray;
@end
