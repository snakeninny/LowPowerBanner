#import "PSViewController.h"

@interface LowPowerBannerListController: PSViewController <UITableViewDelegate, UIApplicationDelegate, UITextFieldDelegate, UIAlertViewDelegate> {
	UITableView *tbView;
}
- (int)numberOfRows;
- (NSMutableArray *)levels;
@end
