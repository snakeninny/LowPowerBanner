@interface TriggerViewController : UITableViewController <UITableViewDelegate, UITextFieldDelegate> {
}
- (BOOL)shouldActWhenPluggedIn;
- (BOOL)shouldActWhenUnplugged;
- (void)actWhenPluggedIn:(BOOL)plugged;
- (void)actWhenUnplugged:(BOOL)unplugged;
@end
