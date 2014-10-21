//
//  BareLedStrip.h
//  Spark_LED
//
//  Created by Steve Michelini on 8/22/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NotificationCenter/NotificationCenter.h>
#import <UIKit/UIKit.h>

@protocol BareLedDelegate <NSObject>

- (void)didFinishUpdateWithStatus:(int)status withCompletionHandler:(void (^)(NCUpdateResult))completionHandler;

@end

@interface BareLedStrip : NSObject

- (id)init;
- (void)updateFromSparkWithDelegate:(id<BareLedDelegate>)delegate withCompletionHandler:(void (^)(NCUpdateResult))completionHandler;
- (void)sendAutoToSparkCloud:(bool)Auto;
@property (nonatomic,strong)UIColor * color;
@property (nonatomic)uint8_t pattern;
@property (nonatomic,strong)NSUserDefaults * defaults;

@end
