//
//  BaseModel.h
//  <>
//
//  Created by Naveen Shan.
//  Copyright © 2015. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject

+ (NSArray *)privateProperties;

+ (NSDictionary *)propertiesMap;

+ (NSDictionary *)dictionaryClassMapping;

+ (NSDictionary *)arrayClassMapping;

- (instancetype)initWithContent:(NSDictionary *)content;

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary;

- (NSMutableDictionary *)dictionary;

+ (NSMutableArray *)arrayWithArray:(NSArray *)contents;

@end
