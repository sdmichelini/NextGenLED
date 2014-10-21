//
//  BareLedStrip.m
//  Spark_LED
//
//  Created by Steve Michelini on 8/22/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import "BareLedStrip.h"


///URL for Spark Cloud
static NSString *const SPARK_API_URL = @"https://api.spark.io/v1/devices/";

@interface BareLedStrip()

@property (nonatomic,strong)NSURL * getUrl;
@property (nonatomic,strong)NSURL * setUrl;

@end

@implementation BareLedStrip

- (id)init
{
    self = [super init];
    if(self)
    {
        self.color = [UIColor whiteColor];
        self.defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.sdmichelini.Spark_LED"];
        
    }
    return self;
}

- (NSURL *)getUrl
{
    if(!_getUrl)
    {
        _getUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/command?access_token=%@",SPARK_API_URL,[self.defaults stringForKey:@"Device ID"],[self.defaults stringForKey:@"API Key"]]];
        NSLog(@"URL: %@",_getUrl);
    }
    return _getUrl;
}


- (NSURL *)setUrl
{
    if(!_setUrl)
    {
        _setUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/change",SPARK_API_URL,[self.defaults stringForKey:@"Device ID"]]];
    }
    return _setUrl;
}


- (void)updateFromSparkWithDelegate:(id<BareLedDelegate>)delegate withCompletionHandler:(void (^)(NCUpdateResult))completionHandler
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue: [NSOperationQueue mainQueue]];
    __weak BareLedStrip * selfI = self;
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
                                                            if(![dict objectForKey:@"result"])
                                                            {
                                                                [delegate didFinishUpdateWithStatus:500 withCompletionHandler:completionHandler];
                                                                return;
                                                            }
                                                            uint32_t command = (uint32_t)((NSNumber*)[dict objectForKey:@"result"]).intValue;
                                                            
                                                            selfI.pattern = (command>>24)&0xF;
                                                            double r,g,b;
                                                            
                                                            r = (double)((command>>16)&0xFF);
                                                            g = (double)((command>>8)&0xFF);
                                                            b = (double)((command)&0xFF);
                                                            
                                                            selfI.color = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
                                                            
                                                            [delegate didFinishUpdateWithStatus:200 withCompletionHandler:completionHandler];
                                                        }
                                                        
                                                    }];
    
    [dataTask resume];
}

- (void)sendAutoToSparkCloud:(bool)Auto
{
    NSString * dataString = (Auto)?@"4ff0000":@"4000000";
    
    NSURLSessionConfiguration * defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * defaultSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:self.setUrl];
    NSString * params = [NSString stringWithFormat:@"access_token=%@&args=%@",[self.defaults stringForKey:@"API Key"],dataString];
    NSLog(@"Params: %@",params);
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           
                                                           
                                                       }];
    [dataTask resume];
}


@end
