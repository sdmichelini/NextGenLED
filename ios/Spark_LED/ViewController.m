//
//  ViewController.m
//  Spark_LED
//
//  Created by Steve Michelini on 8/18/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import "ViewController.h"
#import "LedStrip.h"

@interface ViewController ()<LedStripHandler>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorDisplayHeight;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;
@property (nonatomic,strong) LedStrip * strip;
@property (nonatomic,strong) LedColor * color;
@property (nonatomic) bool needsUpdate;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    self.color = [[LedColor alloc]initWithName:@"current" andColor:[UIColor blackColor]];
    self.colorDisplayHeight.constant = self.colorDisplay.frame.size.width;
    [self.colorDisplay.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.colorDisplay.layer setBorderWidth:5.0f];
    [self updateColorFromSliders];
    [self.commitButton setEnabled:false];
    [self reloadColors];
    [self.strip getCurrentColorWithDelegate:self];
}

- (LedStrip *)strip
{
    if(!_strip)
    {
        _strip = [LedStrip sharedInstance];
    }
    return _strip;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadColors{
    LedColor * c = [[LedColor alloc] initWithName:@"blue" andColorHexString:@"0x0000FF"];
    [self.rSlider setValue:c.r];
    [self.gSlider setValue:c.g];
    [self.bSlider setValue:c.b];
    [self.colorDisplay setBackgroundColor:c.color];
}

- (void)reloadColorsWithColor:(LedColor *)c
{
    [self.rSlider setValue:c.r];
    [self.gSlider setValue:c.g];
    [self.bSlider setValue:c.b];
    [self.colorDisplay setBackgroundColor:c.color];
}

-(void)updateColorFromSliders {
    [self.colorDisplay setBackgroundColor:[UIColor colorWithRed:self.rSlider.value/255.0 green:self.gSlider.value/255.0 blue:self.bSlider.value/255.0 alpha:1.0f]];
    self.needsUpdate = true;
    self.color.r = self.rSlider.value/255.0;
    self.color.g = self.gSlider.value/255.0;
    self.color.b = self.bSlider.value/255.0;
    [self.commitButton setEnabled:true];
}

- (void)didLedGetFinishWithCurrentColor:(LedColor *)color andLedStatusCode:(LedStatusCode)code
{
    if(color)
    {
        [self reloadColorsWithColor:color];
    }
}

- (void)didLedSetFinishWithLedStatusCode:(LedStatusCode)code
{
    
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    [self updateColorFromSliders];
    [self.strip updateCurrentColor:self.color];
}
- (IBAction)loadCurrentColors:(id)sender {
    [self.strip getCurrentColorWithDelegate:self];
}
- (IBAction)commitNewColors:(id)sender {
    [self.strip setCurrentColor:[[LedColor alloc] initWithName:@"Custom" andColor:self.colorDisplay.backgroundColor] withPattern:LedPatternSolid withDelegate:self];
}

@end
