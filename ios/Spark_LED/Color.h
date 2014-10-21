//
//  Color.h
//  Spark_LED
//
//  Created by Steve Michelini on 8/21/14.
//  Copyright (c) 2014 sdmichelini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Color : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * rColor;
@property (nonatomic, retain) NSNumber * gColor;
@property (nonatomic, retain) NSNumber * bColor;
@property (nonatomic, retain) NSNumber * type;

@end
