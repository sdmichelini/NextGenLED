//
//  LedStrip.h
//  Spark_LED
//
//  Created by Steve Michelini on 8/20/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Color.h"
#import "LedColor.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

@protocol LedStripHandler <NSObject>
///All possible Spark Core Errors
typedef enum{
    CodeOk = 200,
    CodeBadRequest = 400,
    CodeUnauthorized = 401,
    CodeForbidden = 403,
    CodeNotFound = 404,
    CodeTimedOut = 408,
    CodeServerError = 500
}LedStatusCode;
///Callback for setting leds
- (void)didLedSetFinishWithLedStatusCode:(LedStatusCode)code;
///Callback for getting led state
- (void)didLedGetFinishWithCurrentColor:(LedColor *)color andLedStatusCode:(LedStatusCode)code;

@end

@interface LedStrip : NSObject
///Types of LED Patterns
typedef enum{
    LedPatternSolid = 1,
    LedPatternFade = 2,
    LedPatternRainbow = 3,
    LedPatternAuto = 4,
    LedPatternSetDayColor = 5,
    LedPatternSetNightColor = 6
} LedPattern;


+ (id)sharedInstance;
//- (id)init;
- (void)getCurrentColorWithDelegate:(id<LedStripHandler>)handler;
- (void)setCurrentColor:(LedColor *)color withPattern:(LedPattern)pattern withDelegate:(id<LedStripHandler>)handler;
- (void)setCurrentColor:(Color *)color;
- (void)updateCurrentColor:(LedColor *)color;
- (void)updateCurrentColorWithColor:(Color *)color;
- (void)setTimeWithHour:(NSInteger)hour withMinute:(NSInteger)minute isWakeTime:(bool)wakeTime;
- (bool)isConnected;

@end
