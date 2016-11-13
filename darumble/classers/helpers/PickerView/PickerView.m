//
//  PickerView.m


#import "PickerView.h"
@implementation PickerView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark- Action Button.
- (IBAction)goDonePicker:(id)sender
{
    [self.delegate donePickerWithIndex:self.IndexSelected];
}

- (IBAction)goCancelPicker:(id)sender {
    [self.delegate cancelPicker];
}

#pragma mark- pickerview delegate.
//Declare for uipicker view.

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.arrPicker count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return [self.arrPicker objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"Row %d",row);
    self.IndexSelected=row;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        [tView setFont:[UIFont fontWithName:@"Lato-Regular" size:16.0f]];
        [tView setTextColor:[UIColor blackColor]];
        tView.backgroundColor =[UIColor clearColor];
        tView.textAlignment = NSTextAlignmentCenter;
        //CGRect frame = CGRectMake(10.0, 0.0, 200.0, 44.0);
        //[tView setFrame:frame];
        
    }
    [tView setText:[self.arrPicker objectAtIndex:row]];
  
   
    return tView;
}
-(void)initFont
{
     [self.lblViewCancel.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:17.0f]];
    [self.lblViewDone.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:17.0f]];
    [self.titlePicker setFont:[UIFont fontWithName:@"Roboto-Light" size:17.0f]];
}



@end
