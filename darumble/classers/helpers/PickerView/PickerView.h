//
//  PickerView.h


#import <UIKit/UIKit.h>

@protocol PickerViewDelegate;

@interface PickerView : UIView <UIPickerViewDataSource,UIPickerViewDelegate>
{
    id<PickerViewDelegate> delegate;
}

@property (nonatomic)    int IndexSelected;
@property (nonatomic,retain)    id<PickerViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *titlePicker;
@property (nonatomic,retain) NSMutableArray *arrPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *lblPicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lblCancel;
@property (weak, nonatomic) IBOutlet UIToolbar *toobarPicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lblDone;
//................................
@property (weak, nonatomic) IBOutlet UIButton *lblViewCancel;
@property (weak, nonatomic) IBOutlet UIButton *lblViewDone;

@property(nonatomic,assign) int typePicker;
@property (weak, nonatomic) IBOutlet UIView *subPicker;

-(void) initFont;
- (IBAction)goDonePicker:(id)sender;
- (IBAction)goCancelPicker:(id)sender;

@end
@protocol PickerViewDelegate <NSObject>

-(void) donePickerWithIndex:(int) index;
-(void) cancelPicker;

@end
