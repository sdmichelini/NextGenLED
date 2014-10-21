//
//  SelectionViewController.m
//  Spark_LED
//
//  Created by Steve Michelini on 8/21/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import "SelectionViewController.h"
#import "ColorTableViewCell.h"
#import "LedColor.h"
#import "LedStrip.h"

@interface SelectionViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) LedStrip * strip;
@property (strong,nonatomic) LedColor * redColor;
@property (strong,nonatomic) LedColor * greenColor;
@property (strong,nonatomic) LedColor * blueColor;
@property (strong,nonatomic) NSArray * colors;
@property (strong,nonatomic) NSArray * commands;
@property (strong,nonatomic) LedColor * autoColor;
@property (strong,nonatomic) LedColor * autoOffColor;
@property (strong,nonatomic) LedColor * rainbowColor;
@property (strong,nonatomic) LedColor * sunriseColor;
@property (strong,nonatomic) LedColor * sunsetColor;
@property (strong,nonatomic) LedColor * dimColor;
@property (weak, nonatomic) IBOutlet UIView *addColorView;
@property (weak, nonatomic) IBOutlet UIView *addColorSample;
@property (weak, nonatomic) IBOutlet UISlider *addColorRed;
@property (weak, nonatomic) IBOutlet UISlider *addColorGreen;
@property (weak, nonatomic) IBOutlet UISlider *addColorBlue;
@property (weak, nonatomic) IBOutlet UISlider *addColorBrightness;
@property (weak, nonatomic) IBOutlet UISegmentedControl *addSegControl;
@property (weak, nonatomic) IBOutlet UIScrollView *addColorScrollView;
@property (weak, nonatomic) IBOutlet UITextField *addColorName;
@property (nonatomic,strong) NSMutableArray * colorArray;

@end

@implementation SelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.addColorName setDelegate:self];
    [self.addColorScrollView setContentInset:UIEdgeInsetsMake(0, ([UIScreen mainScreen].bounds.size.width-320.0)/2.0, 0, 0)];
    self.colorArray = [[NSMutableArray alloc] init];
    [self registerForKeyboardNotifications];
    [self refreshColors];
    [self.addColorView setHidden:true];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.addColorName setDelegate:self];
    self.redColor = [[LedColor alloc] initWithName:@"Red" andColor:[UIColor redColor]];
    self.greenColor = [[LedColor alloc] initWithName:@"Green" andColor:[UIColor greenColor]];
    self.blueColor = [[LedColor alloc] initWithName:@"Blue" andColor:[UIColor blueColor]];
    self.autoColor = [[LedColor alloc]initWithName:@"Auto" andColor:[UIColor colorWithRed:1.0 green:0.7 blue:0.0 alpha:1.0]];
    self.autoOffColor = [[LedColor alloc]initWithName:@"Auto Off" andColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
    self.sunsetColor = [[LedColor alloc]initWithName:@"Sunset" andColor:[UIColor colorWithRed:1.0 green:0.7 blue:0.0 alpha:1.0]];
    self.sunriseColor = [[LedColor alloc]initWithName:@"Sunrise" andColor:[UIColor colorWithRed:1.0 green:0.7 blue:0.7 alpha:1.0]];
    self.dimColor = [[LedColor alloc]initWithName:@"Dim" andColor:[UIColor colorWithRed:0.4 green:0.2 blue:0.0 alpha:1.0]];
    self.rainbowColor = [[LedColor alloc]initWithName:@"Rainbow" andColor:[UIColor blueColor]];
    self.colors = @[self.redColor,self.greenColor,self.blueColor];
    self.commands = @[self.autoColor,self.autoOffColor,self.sunriseColor,self.sunsetColor,self.dimColor,self.rainbowColor];
    [self.addColorSample setBackgroundColor:[UIColor colorWithRed:[self.addColorRed value]
                                                            green:[self.addColorGreen value]
                                                             blue:[self.addColorBlue value]
                                                            alpha:[self.addColorBrightness value]]];
    // Do any additional setup after loading the view.
}

- (void)reloadFromCoreData
{
    AppDelegate * appDel = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext * context = [appDel managedObjectContext];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Color"];
    [self.colorArray removeAllObjects];
    [self.colorArray addObjectsFromArray:[context executeFetchRequest:request error:nil]];
}

- (void)refreshColors
{
    [self reloadFromCoreData];
    if(self.colorArray)
    {
        [self.tableView reloadData];
    }
    else
    {
        NSLog(@"No Colors to Fetch");
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.addColorScrollView setContentInset:UIEdgeInsetsMake(0, (size.width-320.0)/2.0, 0, 0)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (LedStrip *)strip
{
    if(!_strip)
    {
        _strip = [LedStrip sharedInstance];
    }
    return _strip;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ColorTableViewCell * cell = (ColorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"colorTableView"];
    if(indexPath.section==1){
        [cell setColor:self.colors[indexPath.row]];
    }
    else if(indexPath.section==2)
    {
        [cell setColorFromDatabase:self.colorArray[indexPath.row]];
    }
    else{
        [cell setColor:self.commands[indexPath.row]];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==1)
    {
        return self.colors.count;
    }
    else if(section==2)
    {
        return self.colorArray.count;
    }
    else
    {
        return self.commands.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.strip isConnected])
    {
        if(indexPath.section == 1)
        {
            [self.strip updateCurrentColor:self.colors[indexPath.row]];
        }
        else if(indexPath.section == 2)
        {
            [self.strip updateCurrentColorWithColor:self.colorArray[indexPath.row]];
        }
        else{
            [self.strip updateCurrentColor:self.commands[indexPath.row]];
        }
    }
    else
    {
        if(indexPath.section == 1)
        {
            [self.strip setCurrentColor:self.colors[indexPath.row] withPattern:LedPatternSolid withDelegate:nil];
        }
        else if(indexPath.section == 2)
        {
            [self.strip setCurrentColor:self.colorArray[indexPath.row]];
        }
        else
        {
            if([((LedColor*)self.commands[indexPath.row]).name isEqualToString:@"Auto"])
            {
                [self.strip setCurrentColor:self.commands[indexPath.row] withPattern:LedPatternAuto withDelegate:nil];
            }
            else if([((LedColor*)self.commands[indexPath.row]).name isEqualToString:@"Auto Off"])
            {
                [self.strip setCurrentColor:self.commands[indexPath.row] withPattern:LedPatternAuto withDelegate:nil];
            }
            else if([((LedColor*)self.commands[indexPath.row]).name isEqualToString:@"Rainbow"])
            {
                [self.strip setCurrentColor:self.commands[indexPath.row] withPattern:LedPatternRainbow withDelegate:nil];
            }
            else{
                [self.strip setCurrentColor:self.commands[indexPath.row] withPattern:LedPatternSolid withDelegate:nil];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        [context deleteObject:self.colorArray[indexPath.row]];
        [context save:nil];
        [self reloadFromCoreData];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return @"Commands";
    }
    else if(section == 2)
    {
        return @"Custom Colors";
    }
    else
    {
        return @"Colors";
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

- (IBAction)addColor:(id)sender {
    if(self.addColorName.hasText)
    {
        AppDelegate * appDel = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext * context = [appDel managedObjectContext];
        NSEntityDescription * entity = [NSEntityDescription entityForName:@"Color" inManagedObjectContext:context];
        
        Color * c = [[Color alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        
        c.rColor = [NSNumber numberWithDouble:[self.addColorRed value]*[self.addColorBrightness value]];
        c.gColor = [NSNumber numberWithDouble:[self.addColorGreen value]*[self.addColorBrightness value]];
        c.bColor = [NSNumber numberWithDouble:[self.addColorBlue value]*[self.addColorBrightness value]];
        c.name = [self.addColorName text];
        c.type = [NSNumber numberWithShort:(uint16_t)[self.addSegControl selectedSegmentIndex]+1];
        
        if(![context save:nil])
        {
            NSLog(@"Error Saving Data");
        }
        [self refreshColors];
        [self.addColorView setHidden:true];
    }
}
- (IBAction)cancelAddColor:(id)sender {
    if(self.addColorName.isFirstResponder)
    {
        [self.addColorName resignFirstResponder];
    }
    [self.addColorView setHidden:true];
}
- (IBAction)changedSlider:(id)sender {
    [self.addColorSample setBackgroundColor:[UIColor colorWithRed:[self.addColorRed value]
                                                            green:[self.addColorGreen value]
                                                             blue:[self.addColorBlue value]
                                                            alpha:[self.addColorBrightness value]]];
}
- (IBAction)addButtonClicked:(id)sender {
    [self.addColorView setHidden:false];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}
- (IBAction)editButtonClicked:(id)sender {
    if(self.addColorView.isHidden)
    {
        if(self.tableView.isEditing)
        {
            [self.tableView setEditing:NO];
        }
        else{
            [self.tableView setEditing:YES];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGRect keyboardFrameBeginRect = [[[aNotification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    CGFloat init_pos_from_bottom = [self.addColorScrollView frame].size.height-(self.addColorName.frame.origin.y+self.addColorName.frame.size.height);
    CGFloat keyboardHeight = keyboardFrameBeginRect.size.height;
    [self.addColorScrollView setContentOffset:CGPointMake(0.0, (keyboardHeight-init_pos_from_bottom)) animated:NO];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.addColorScrollView setContentOffset:CGPointZero animated:NO];
}

@end
