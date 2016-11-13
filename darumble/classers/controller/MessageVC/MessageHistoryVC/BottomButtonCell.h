//
//  SimpleTableCell.h
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageHistoryVC.h"

@interface BottomButtonCell : UITableViewCell

@property MessageHistoryVC *parent;
@property int to_user;
@end
