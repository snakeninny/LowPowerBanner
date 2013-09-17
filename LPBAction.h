@interface LPBAction : NSObject {
}
- (void)actionOfKind:(NSString *)kind atBatteryLevel:(NSInteger)batteryLevel;
@end
