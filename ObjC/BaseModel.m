//
//  BaseModel.m
//  <>
//
//  Created by Naveen Shan.
//  Copyright © 2015. All rights reserved.
//

#import "BaseModel.h"

#import <objc/runtime.h>

@interface BaseModel ()

@property (nonatomic, strong) NSMutableArray *propertyNames;

@end

@implementation BaseModel

#pragma mark -

- (instancetype)initWithContent:(NSDictionary *)content {
    self = [super init];
    if (self) {
        [self setContents:content];
    }
    return self;
}

+ (NSDictionary *)arrayClassMapping  {
    return nil;
}

+ (NSDictionary *)dictionaryClassMapping  {
    return nil;
}

+ (NSArray *)privateProperties  {
    return nil;
}

+ (NSDictionary *)propertiesMap  {
    return nil;
}

#pragma mark -

- (NSArray *)allPropertyNames   {
    if (self.propertyNames) {
        return self.propertyNames;
    }
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *propertyValues = [NSMutableArray array];
    
    unsigned i;
    for (i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [propertyValues addObject:name];
    }
    NSArray *pvtProperties = [[self class] privateProperties];
    [propertyValues removeObjectsInArray:pvtProperties];
    
    free(properties);
    
    self.propertyNames = propertyValues;
    return self.propertyNames;
}

- (id)convertValueDataTypeToKVOIfRequired:(id)value {
    if (! value) {
        return value;
    }
    if ([value isKindOfClass:[NSArray class]]) {
        value = [[self class] arrayWithModel:value];
    } else if ([value isKindOfClass:[BaseModel class]]) {
        value = [value dictionary];
    }
    return value;
}

- (id)convertValueDataTypeFromKVOIfRequired:(id)value property:(NSString *)property {
    if (! value) {
        return value;
    }

    if ([value isKindOfClass:[NSArray class]]) {
        NSDictionary *arrayMapping = [[self class] arrayClassMapping];
        Class classType = [arrayMapping objectForKey:property];
        if (classType) {
            value = [classType arrayWithArray:value];
        }
    }
    else if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *arrayMapping = [[self class] dictionaryClassMapping];
        Class classType = [arrayMapping objectForKey:property];
        if (classType) {
            value = [[classType alloc] initWithContent:value];
        }
    }
    return value;
}

- (void)setContents:(NSDictionary *)content {
    if (! [content isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSArray *propertyNames = [self allPropertyNames];
    for (NSString *property in propertyNames) {
        NSString *propertiesMapKey = [[[self class] propertiesMap] objectForKey:property];
        if (!propertiesMapKey) {
            propertiesMapKey = property;
        }
        
        id value = [content valueForKey:propertiesMapKey];
        value = [self convertValueDataTypeFromKVOIfRequired:value property:property];
        if (value && (NSNull *)value != [NSNull null]) {
            [self setValue:value forKey:property];
        }
    }
}

#pragma mark -

- (NSMutableDictionary *)dictionary {
    NSArray *propertyNames = [self allPropertyNames];
    
    NSMutableDictionary *contents = [NSMutableDictionary dictionaryWithCapacity:[propertyNames count]];
    for (NSString *property in propertyNames) {
        id value = [self valueForKey:property];
        
        value = [self convertValueDataTypeToKVOIfRequired:value];
        if (value && (NSNull *)value != [NSNull null]) {
            NSString *propertiesMapKey = [[[self class] propertiesMap] objectForKey:property];
            if (!propertiesMapKey) {
                propertiesMapKey = property;
            }
            [contents setValue:value forKey:propertiesMapKey];
        }
    }
    
    return contents;
}

+ (NSMutableArray *)arrayWithArray:(NSArray *)contents {
    if (! [contents isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *content in contents) {
        id object = [[[self class] alloc] initWithContent:content];
        [array addObject:object];
    }
    return array;
}

+ (NSMutableArray *)arrayWithModel:(NSArray *)contents {
    if (! [contents isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    for (BaseModel *content in contents) {
        if ([content respondsToSelector:@selector(dictionary)]) {
            [array addObject:[content dictionary]];
        } else {
            [array addObject:content];
        }
    }
    return array;
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithContent:dictionary];
}

@end
