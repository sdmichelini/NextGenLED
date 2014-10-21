//
//  ViewController.h
//  Spark_LED
//
//  Created by Steve Michelini on 8/18/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *colorDisplay;
@property (weak, nonatomic) IBOutlet UISlider *rSlider;
@property (weak, nonatomic) IBOutlet UISlider *gSlider;
@property (weak, nonatomic) IBOutlet UISlider *bSlider;

@end

