@interface IconViewController : UITableViewController {
	NSString *levelString;
	NSString *typeString;
	NSString *iconString;
	NSMutableArray *iconsArray;
}
- (void)loadAllIcons;
- (UIImage *)loadImageAtIndex:(NSUInteger)index;
- (UIImage *)compressImage:(UIImage *)image;
- (void)saveConfig;

@property (nonatomic, retain) NSString *levelString;
@property (nonatomic, retain) NSString *typeString;
@property (nonatomic, retain) NSString *iconString;
@property (nonatomic, retain) NSMutableArray *iconsArray;
@end
