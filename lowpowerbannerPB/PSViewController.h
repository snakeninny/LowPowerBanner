@interface PSViewController : UITableViewController <UITableViewDelegate> {
}
-(void)setParentController:(id)controller;
-(id)parentController;
-(void)setRootController:(id)controller;
-(id)rootController;
-(void)dealloc;
-(void)setSpecifier:(id)specifier;
-(id)specifier;
-(void)setPreferenceValue:(id)value specifier:(id)specifier;
-(id)readPreferenceValue:(id)value;
-(void)willResignActive;
-(void)willBecomeActive;
-(void)suspend;
-(void)didLock;
-(void)willUnlock;
-(void)didUnlock;
-(void)didWake;
-(void)pushController:(id)controller;
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation;
-(void)handleURL:(id)url;
-(id)methodSignatureForSelector:(SEL)selector;
-(void)forwardInvocation:(id)invocation;
-(void)popupViewWillDisappear;
-(void)popupViewDidDisappear;
-(void)formSheetViewWillDisappear;
-(void)formSheetViewDidDisappear;
-(BOOL)canBeShownFromSuspendedState;
-(void)statusBarWillAnimateByHeight:(float)statusBar;
@end

