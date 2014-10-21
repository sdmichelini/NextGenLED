//
//  LedColor.m
//  Spark_LED
//
//  Created by Steve Michelini on 8/18/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import "LedColor.h"


@implementation LedColor

- (id)initWithName:(NSString *)name andColor:(UIColor *)color
{
    self = [super init];
    if(self)
    {
        self.name = name;
        self.color = color;
        [self determineColors];
    }
    return self;
}

-(id)initWithName:(NSString *)name andColorHexString:(NSString *)hexString
{
    self = [super init];
    if(self)
    {
        self.name = name;
        if(hexString.length!=8&&hexString.length!=6)
        {
            return nil;
        }
        else if(hexString.length==8)
        {
            hexString = [hexString substringFromIndex:2];
        }
        NSScanner * scan = [[NSScanner alloc]initWithString:hexString];
        unsigned int rgbHex;
        [scan scanHexInt:&rgbHex];
        unsigned int r = (rgbHex&0xFF0000)>>16;
        unsigned int g = (rgbHex&0xFF00)>>8;
        unsigned int b = rgbHex&0xFF;
        self.r = (float)r;
        self.g = (float)g;
        self.b = (float)b;
        self.color = [UIColor colorWithRed:((float)r/255.0f) green:((float)g/255.0f) blue:((float)b/255.0f) alpha:1.0f];
        
    }
    return self;
}

-(id)initWithInt:(uint32_t)val andName:(NSString *)name
{
    self = [super init];
    if(self)
    {
        self.name = name;
        
        val = val&0xFFFFFF;
        
        uint8_t r = (val>>16)&0xFF;
        uint8_t g = (val>>8)&0xFF;
        uint8_t b = (val)&0xFF;
        
        self.r = (float)r;
        self.g = (float)g;
        self.b = (float)b;
        self.color = [UIColor colorWithRed:((float)r/255.0f) green:((float)g/255.0f) blue:((float)b/255.0f) alpha:1.0f];
        
    }
    return self;
}

- (void) determineColors;
{
    double r,g,b,a;
    [self.color getRed:&r green:&g blue:&b alpha:&a];
    self.r = r;
    self.g = g;
    self.b = b;
}

- (NSData *)getData
{
    NSMutableData * ret = [[NSMutableData alloc] initWithLength:4];
    uint8_t patternCast = 1;
    [ret replaceBytesInRange:NSMakeRange(0, 1) withBytes:(uint8_t*)&patternCast];
    uint8_t r = (uint8_t)(self.r*255.0);
    uint8_t g = (uint8_t)(self.g*255.0);
    uint8_t b = (uint8_t)(self.b*255.0);
    [ret replaceBytesInRange:NSMakeRange(1, 1) withBytes:&r];
    [ret replaceBytesInRange:NSMakeRange(2, 1) withBytes:&g];
    [ret replaceBytesInRange:NSMakeRange(3, 1) withBytes:&b];
    return [ret mutableCopy];
}

@end
