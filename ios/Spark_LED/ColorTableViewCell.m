//
//  ColorTableViewCell.m
//  Spark_LED
//
//  Created by Steve Michelini on 8/21/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import "ColorTableViewCell.h"

@implementation ColorTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setColor:(LedColor *)color
{
    [self.colorView setBackgroundColor:color.color];
    [self.colorLabel setText:color.name];
}

- (void)setColorFromDatabase:(Color *)color
{
    [self.colorView setBackgroundColor:[UIColor colorWithRed:color.rColor.doubleValue green:color.gColor.doubleValue blue:color.bColor.doubleValue alpha:1.0]];
    [self.colorLabel setText:color.name];
}

@end
