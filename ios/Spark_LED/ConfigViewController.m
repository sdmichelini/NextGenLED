//
//  ConfigViewController.m
//  Spark_LED
//
//  Created by Steve Michelini on 9/9/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import "ConfigViewController.h"
#import "ConfigTableViewCell.h"
#import "LedStrip.h"

@interface ConfigViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *setColorView;
@property (weak, nonatomic) IBOutlet UIView *setTimeView;
@property (weak, nonatomic) IBOutlet UIDatePicker *timeDatePicker;
@property (weak, nonatomic) IBOutlet UIView *colorPicker;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic) bool isDaySelected;

@end

@implementation ConfigViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self.setColorView setHidden:true];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.setTimeView setHidden:true];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self updateValues];
    self.isDaySelected = false;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
        {
            ConfigTableViewCell * cell = (ConfigTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"configCell"];
            cell.label.text = @"Set Daytime Color";
            return cell;
        }
        else{
            ConfigTableViewCell * cell = (ConfigTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"configCell"];
            cell.label.text = @"Set Nightime Color";
            return cell;
        }
    }
    else
    {
        if(indexPath.row==0)
        {
            ConfigTableViewCell * cell = (ConfigTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"configCell"];
            cell.label.text = @"Set Wake Time";
            return cell;
        }
        else{
            ConfigTableViewCell * cell = (ConfigTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"configCell"];
            cell.label.text = @"Set Sleep Time";
            return cell;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
        return @"Auto Color Config";
    }
    else
    {
        return @"Auto Time Config";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        [self.setColorView setHidden:false];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:false];
        if(indexPath.row==0)
        {
            self.isDaySelected = true;
        }
        else{
            self.isDaySelected = false;
        }
    }
    else if(indexPath.section==1)
    {
        [self.setColorView setHidden:true];
        [self.setTimeView setHidden:false];
        if(indexPath.row==0)
        {
            self.timeLabel.text = @"Set Day Time";
            self.isDaySelected = true;
        }
        else if(indexPath.row==1)
        {
            self.timeLabel.text =@"Set Night Time";
            self.isDaySelected = false;
        }
    }
}
- (IBAction)didCommitColor:(id)sender {
    [self.setColorView setHidden:true];
    LedPattern pattern= ([self isDaySelected])?LedPatternSetDayColor:LedPatternSetNightColor;
    [[LedStrip sharedInstance] setCurrentColor:[[LedColor alloc] initWithName:@"Custom"andColor:[UIColor colorWithRed:[self.redSlider value] green:self.greenSlider.value blue:self.blueSlider.value alpha:1.0]] withPattern:pattern withDelegate:nil];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:false];

}
- (IBAction)didCancelColor:(id)sender {
    [self.setColorView setHidden:true];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:false];

}

-(void)updateValues
{
    [self.colorPicker setBackgroundColor:[UIColor colorWithRed:[self.redSlider value] green:self.greenSlider.value blue:self.blueSlider.value alpha:1.0]];
}
- (IBAction)sliderDidChange:(id)sender {
    [self updateValues];
}
- (IBAction)didCancelTime:(id)sender {
    [self.setTimeView setHidden:true];
}
- (IBAction)didCommitTime:(id)sender {
    [self.setTimeView setHidden:true];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[self.timeDatePicker date]];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    [[LedStrip sharedInstance]setTimeWithHour:hour withMinute:minute isWakeTime:self.isDaySelected];
    NSLog(@"Hour:%ld Minute:%ld",hour,minute);
}

@end
