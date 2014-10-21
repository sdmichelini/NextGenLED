//
//  LedColor.h
//  Spark_LED
//
//  Created by Steve Michelini on 8/18/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LedColor : NSObject

-(id)initWithName:(NSString *)name andColor:(UIColor*)color;
-(id)initWithInt:(uint32_t)val andName:(NSString *)name;
-(id)initWithName:(NSString *)name andColorHexString:(NSString *)hexString;

-(NSData *)getData;

@property (nonatomic,strong)NSString * name;
@property (nonatomic,strong)UIColor * color;
@property (nonatomic) double r;
@property (nonatomic) double g;
@property (nonatomic) double b;

@end
