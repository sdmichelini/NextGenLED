//
//  TodayViewController.m
//  Spark Extension
//
//  Created by Steve Michelini on 8/22/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import "TodayViewController.h"
#import "BareLedStrip.h"

#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding,BareLedDelegate>
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *Label;
@property (nonatomic,strong)BareLedStrip * strip;
@property (weak, nonatomic) IBOutlet UIButton *autoButton;
@property (weak, nonatomic) IBOutlet UIButton *offButton;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.strip = [[BareLedStrip alloc] init];
    self.preferredContentSize = CGSizeMake(320, 70);
  
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    [self.Label setText:@"Updating..."];
    [self.colorView setHidden:true];
    [self.typeLabel setHidden:true];
    [self.offButton setHidden:true];
    [self.autoButton setHidden:true];
    [self.strip updateFromSparkWithDelegate:self withCompletionHandler:completionHandler];
    
}

- (void)didFinishUpdateWithStatus:(int)status withCompletionHandler:(void (^)(NCUpdateResult))completionHandler
{
    if(status!=200)
    {
        [self.colorView setHidden:true];
        [self.typeLabel setHidden:true];
        [self.Label setText:@"Error"];
        completionHandler(NCUpdateResultFailed);
        return;
    }
    completionHandler(NCUpdateResultNewData);
    [self.colorView setHidden:false];
    [self.Label setText:@"Current Color Pattern:"];
    [self.typeLabel setHidden:false];
    [self.offButton setHidden:false];
    [self.autoButton setHidden:false];
    [self.colorView setBackgroundColor:self.strip.color];
    if(self.strip.pattern==1)
    {
        self.typeLabel.text = @"Solid";
    }
    else if(self.strip.pattern==2)
    {
        self.typeLabel.text = @"Fade";
    }
    else if(self.strip.pattern==3)
    {
        self.typeLabel.text = @"Rainbow";
    }
    else if(self.strip.pattern==4)
    {
        self.typeLabel.text = @"Auto";
    }
    NSLog(@"Here");

}
- (IBAction)didHitAuto:(id)sender {
    [self.strip sendAutoToSparkCloud:true];
}
- (IBAction)didHitOff:(id)sender {
    [self.strip sendAutoToSparkCloud:false];
}

@end
