//
//  TFJSONSchemaValidator.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 04/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import "TFJSONSchemaValidator.h"

static NSString *kJSONSchemaValidationDomain = @"JSON Validation";
static NSString *kJSONSchemaValidationPathDelimiter = @"->";

@implementation TFJSONSchemaValidator

static TFJSONSchemaValidator *validator;
+ (TFJSONSchemaValidator *)validator
{
    if(!validator){
        validator = [[TFJSONSchemaValidator alloc] init];
    }
    
    return validator;
}

- (NSError *)validate:(NSDictionary *)jsonObject withSchema:(NSDictionary *)schema
{
    if(!jsonObject) return [self errorWithMessage:@"Must supply a dictonary to validate"];
    if(!schema) return [self errorWithMessage:@"Must supply a schema"];

    NSArray *errors = [self validate:jsonObject atPath:@"" withSchema:schema];
    
    if(errors.count > 0){
        return [NSError errorWithDomain:kJSONSchemaValidationDomain code:1 userInfo:@{@"message" : @"Validation failed", @"errors" : errors}];
    }
    return nil;
}


- (NSArray *)validate:(NSObject *)value atPath:(NSString *)path withSchema:(NSDictionary *)schema;
{
    NSMutableArray *errors = [NSMutableArray array];
    NSString *type = schema[@"type"];
    
    if([type isEqualToString:@"object"]){
        [errors addObjectsFromArray:[self validateObject:value atPath:path withSchema:schema]];
    } else if([type isEqualToString:@"string"]){
        NSError *error = [self validateString:value atPath:path withSchema:schema];
        if(error){
            [errors addObject:error];
        }
    } else {
        [errors addObject:[self errorWithMessage:[NSString stringWithFormat:@"%@ is of unsupported type at %@", type, path]]];
    }
    return errors;
}

- (NSError *)validateString:(NSObject *)value atPath:(NSString *)path withSchema:(NSDictionary *)schema
{
    if(![value isKindOfClass:NSString.class]){
        return [self errorWithMessage:[NSString stringWithFormat:@"%@ is not a string", path]];
    }
    NSString *str = (NSString *)value;
    NSNumber *maxLength = schema[@"maxLength"];
    if(maxLength && str.length > [maxLength integerValue]){
        return [self errorWithMessage:[NSString stringWithFormat:@"%@ has a length > %d", path, [maxLength integerValue]]];
    }

    NSNumber *minLength = schema[@"minLength"];
    if(minLength && str.length < [minLength integerValue]){
        return [self errorWithMessage:[NSString stringWithFormat:@"%@ has a length < %d", path, [minLength integerValue]]];
    }

    return nil;
}

- (NSArray *)validateObject:(NSObject *)value atPath:(NSString *)path withSchema:(NSDictionary *)schema
{
    if(![value isKindOfClass:NSDictionary.class]){
        return @[[self errorWithMessage:[NSString stringWithFormat:@"%@ is not a object", path]]];
    }
    
    NSDictionary *obj = (NSDictionary *)value;

    NSMutableArray *errors = [NSMutableArray new];
    NSDictionary *properties = schema[@"properties"];
    for(NSString *property in properties){
        NSString *newPath = [path isEqualToString:@""] ? property : [NSString stringWithFormat:@"%@%@%@", path, kJSONSchemaValidationPathDelimiter, property];
        if(obj[property] && properties[property]){
            [errors addObjectsFromArray:[self validate:obj[property] atPath:newPath withSchema:properties[property]]];
        }
    }
    
    return errors;
}

- (NSError *)errorWithMessage:(NSString *)message
{
    return [NSError errorWithDomain:kJSONSchemaValidationDomain code:0 userInfo:@{@"message" : message}];
}

- (NSString *)prettyPrintErrors:(NSError *)errors
{
    if(!errors){
        return @"";
    }
    
    NSString *str = errors.userInfo[@"message"];
    
    for(NSError *error in errors.userInfo[@"errors"]){
        str = [NSString stringWithFormat:@"%@\nERROR:%@", str, error.userInfo[@"message"]];
    }
    
    return str;
}
@end