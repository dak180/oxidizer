@protocol QuickViewProtocol

-(void) setMinimum:(double) min andMaximum:(double) max;
-(void) renderQuickViews;
-(void) resetToOriginalValue;
-(void) setToValue:(id)value;

@end