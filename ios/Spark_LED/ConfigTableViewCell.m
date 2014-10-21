//
//  ConfigTableViewCell.m
//  Spark_LED
//
//  Created by Steve Michelini on 9/9/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import "ConfigTableViewCell.h"

@implementation ConfigTableViewCell

- (void)awakeFromNib {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
