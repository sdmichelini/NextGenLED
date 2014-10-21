//
//  ColorTableViewCell.h
//  Spark_LED
//
//  Created by Steve Michelini on 8/21/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LedColor.h"
#import "Color.h"

@interface ColorTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *colorLabel;

@property (strong,nonatomic) LedColor * color;

- (void)setColorFromDatabase:(Color *)color;

@end
