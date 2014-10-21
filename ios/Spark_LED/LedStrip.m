//
//  LedStrip.m
//  Spark_LED
//
//  Created by Steve Michelini on 8/20/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import "LedStrip.h"

///URL for Spark Cloud
static NSString *const SPARK_API_URL = @"https://api.spark.io/v1/devices/";
///Unique Spark Core Device ID
static NSString *const DEVICE_ID = @"12345";
///Spark Core API Key
static NSString *const API_KEY = @"12345";

///Spark Core API Key
static NSString *const SPARK_IP = @"10.xx.xx.xx";

#define TIME_DELTA 0.050

@interface LedStrip()<GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate>
///HTTP Session for doing transactions with Spark Core
@property (nonatomic,strong)NSURLSession * httpSession;
///URL for setting color
@property (nonatomic,strong)NSURL * setUrl;
@property (nonatomic,strong)NSURL * timeUrl;
///URL for getting color
@property (nonatomic,strong)NSURL * getUrl;

@property (nonatomic,strong)NSString * localIP;

@property (nonatomic) bool connected;

@property (nonatomic,strong)GCDAsyncSocket * sparkSocket;
@property (nonatomic,strong)GCDAsyncUdpSocket * sparkUDPSocket;
@property (nonatomic,strong)NSUserDefaults * defaults;

@property (nonatomic) double lastTimeSent;

@end

@implementation LedStrip

+ (id)sharedInstance
{
    static LedStrip * strip;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strip = [[self alloc] init];
    });
    return strip;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.connected = false;
        [self.sparkSocket connectToHost:SPARK_IP onPort:36501 error:nil];
        self.lastTimeSent = 0.0;
        self.defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.sdmichelini.Spark_LED"];
        [self.defaults setValue:DEVICE_ID forKey:@"Device ID"];
        [self.defaults setValue:API_KEY forKey:@"API Key"];
        [self.defaults synchronize];
        
    }
    return self;
}

- (NSURL *)setUrl
{
    if(!_setUrl)
    {
        _setUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/change",SPARK_API_URL,DEVICE_ID]];
    }
    return _setUrl;
}

- (NSURL *)timeUrl
{
    if(!_setUrl)
    {
        _setUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/setTime",SPARK_API_URL,DEVICE_ID]];
    }
    return _setUrl;
}

- (NSURL *)getUrl
{
    if(!_getUrl)
    {
        _getUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/command?access_token=%@",SPARK_API_URL,DEVICE_ID,API_KEY]];
    }
    return _getUrl;
}

- (GCDAsyncSocket *)sparkSocket
{
    if(!_sparkSocket)
    {
        _sparkSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _sparkSocket;
}

- (GCDAsyncUdpSocket *)sparkUDPSocket
{
    if(!_sparkUDPSocket)
    {
        _sparkUDPSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _sparkUDPSocket;
}

+ (NSData *)convertRequestToDataWithColor:(LedColor *)color withPattern:(LedPattern)pattern
{
    NSMutableData * ret = [[NSMutableData alloc] initWithLength:4];
    uint8_t patternCast = (uint8_t)pattern;
    [ret replaceBytesInRange:NSMakeRange(0, 1) withBytes:(uint8_t*)&patternCast];
    uint8_t r = (uint8_t)(color.r*255.0);
    uint8_t g = (uint8_t)(color.g*255.0);
    uint8_t b = (uint8_t)(color.b*255.0);
    [ret replaceBytesInRange:NSMakeRange(1, 1) withBytes:&r];
    [ret replaceBytesInRange:NSMakeRange(2, 1) withBytes:&g];
    [ret replaceBytesInRange:NSMakeRange(3, 1) withBytes:&b];
    return [ret mutableCopy];
}

+ (NSData *)convertRequestToDataWithColor:(Color *)color
{
    NSMutableData * ret = [[NSMutableData alloc] initWithLength:4];
    uint8_t patternCast = (uint8_t)color.type.shortValue;
    [ret replaceBytesInRange:NSMakeRange(0, 1) withBytes:(uint8_t*)&patternCast];
    uint8_t r = (uint8_t)(color.rColor.doubleValue*255.0);
    uint8_t g = (uint8_t)(color.gColor.doubleValue*255.0);
    uint8_t b = (uint8_t)(color.bColor.doubleValue*255.0);
    [ret replaceBytesInRange:NSMakeRange(1, 1) withBytes:&r];
    [ret replaceBytesInRange:NSMakeRange(2, 1) withBytes:&g];
    [ret replaceBytesInRange:NSMakeRange(3, 1) withBytes:&b];
    NSLog(@"Color: %@",ret);
    return [ret mutableCopy];
}

- (void)getCurrentColorWithDelegate:(id<LedStripHandler>)handler
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue: [NSOperationQueue mainQueue]];
    
    
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:self.getUrl
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if(error == nil)
                                                        {
                                                            __block NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                            NSLog(@"Data = %@",text);
                                                            __block NSError * error = nil;
                                                            __block NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                          options:kNilOptions
                                                                                                                            error:&error];
                                                            NSLog(@"Return: %d",((NSNumber*)[dict objectForKey:@"result"]).intValue);
                                                            
                                                            uint32_t command = (uint32_t)((NSNumber*)[dict objectForKey:@"result"]).intValue;
                                                            
                                                            __block LedColor * color = [[LedColor alloc] initWithInt:command andName:@"current color"];
                                                            
                                                            [handler didLedGetFinishWithCurrentColor:color andLedStatusCode:(LedStatusCode)[(NSHTTPURLResponse*)response statusCode]];
                                                        }
                                                        
                                                    }];
    
    [dataTask resume];
}

- (void)setCurrentColor:(LedColor *)color withPattern:(LedPattern)pattern withDelegate:(id<LedStripHandler>)handler
{
    //first convert pattern to NSData
    NSData * data = [LedStrip convertRequestToDataWithColor:color withPattern:pattern];
    [self sendDataToSparkCloud:data withDelegate:handler];
}

- (void)sendDataToSparkCloud:(NSData *)data withDelegate:(id<LedStripHandler>)handler
{
    NSString * dataString = [[NSString stringWithFormat:@"%@",data] substringWithRange:NSMakeRange(2, 7)];
    
    NSURLSessionConfiguration * defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * defaultSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:self.setUrl];
    NSString * params = [NSString stringWithFormat:@"access_token=%@&args=%@",API_KEY,dataString];
    NSLog(@"Params: %@",params);
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil)
                                                           {
                                                               [handler didLedSetFinishWithLedStatusCode:(LedStatusCode)[(NSHTTPURLResponse*)response statusCode]];
                                                           }
                                                           
                                                       }];
    [dataTask resume];
}

- (void)setCurrentColor:(Color *)color
{
    NSData * data = [LedStrip convertRequestToDataWithColor:color];
    [self sendDataToSparkCloud:data withDelegate:nil];
}



- (void)updateCurrentColorWithColor:(Color *)color
{
    if(self.connected)
    {
        if(CACurrentMediaTime() - self.lastTimeSent > TIME_DELTA)
        {
            self.lastTimeSent = CACurrentMediaTime();
            uint32_t data = (uint32_t)[[LedStrip convertRequestToDataWithColor:color] bytes];
            data = htonl(data);
            
            [self.sparkSocket writeData:[NSData dataWithBytes:data length:sizeof(data)] withTimeout:1.0 tag:1];
        }
    }

}

- (void)updateCurrentColor:(LedColor *)color
{
    if(self.connected)
    {
        if(CACurrentMediaTime() - self.lastTimeSent > TIME_DELTA)
        {
            self.lastTimeSent = CACurrentMediaTime();
            if(self.sparkSocket.isConnected)
            {
                [self.sparkSocket writeData:[LedStrip convertRequestToDataWithColor:color withPattern:LedPatternSolid] withTimeout:10000 tag:1];
            }
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    self.connected = true;
    NSLog(@"Connected to HOST");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (bool)isConnected
{
    return self.connected;
}

- (void)setTimeWithHour:(NSInteger)hour withMinute:(NSInteger)minute isWakeTime:(bool)wakeTime
{
    NSString * dataString;
    if(wakeTime)
    {
        dataString= [NSString stringWithFormat:@"%2ld:%2ld45:99",(long)hour,(long)minute];
    }
    else{
        dataString= [NSString stringWithFormat:@"45:99%2ld:%2ld",(long)hour,(long)minute];
    }
    
    NSURLSessionConfiguration * defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * defaultSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:self.timeUrl];
    NSString * params = [NSString stringWithFormat:@"access_token=%@&args=%@",API_KEY,dataString];
    NSLog(@"Params: %@",params);
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           
                                                       }];
    [dataTask resume];
}

- (void)dealloc
{
    if([self.sparkSocket isConnected])
    {
        [self.sparkSocket disconnect];
    }
    [self.sparkUDPSocket close];
}

@end
