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

- (NSError *)validate:(NSDictionary *)jsonObject withSchemaPath:(NSString *)path
{
    return [self validate:jsonObject withSchemaPath:path bundle:[NSBundle mainBundle]];
}

- (NSError *)validate:(NSDictionary *)jsonObject withSchemaPath:(NSString *)path bundle:(NSBundle *)bundle
{
    NSString *realPath = [bundle pathForResource:path ofType:@"json"];
    NSError *error;
    NSDictionary *schema = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:realPath] options: NSJSONReadingMutableContainers error: &error];
    if(error){
        return [self errorWithMessage:@""];
    }
    return [self validate:jsonObject withSchema:schema];
}



- (NSError *)validate:(NSDictionary *)jsonObject withSchema:(NSDictionary *)schema
{
    if(!jsonObject) return [self errorWithMessage:@"Must supply a dictonary to validate"];
    if(!schema) return [self errorWithMessage:@"Must supply a schema"];

    NSMutableDictionary *definitions = [schema[@"definitions"] mutableCopy];
    if(!definitions){
        definitions = [NSMutableDictionary new];
    }
    definitions[@"#"] = schema;
    
    NSArray *errors = [self validate:jsonObject atPath:@"" schema:schema definitions:definitions];
    
    if(errors.count > 0){
        return [NSError errorWithDomain:kJSONSchemaValidationDomain code:1 userInfo:@{@"message" : @"Validation failed", @"errors" : errors}];
    }
    return nil;
}


- (NSArray *)validate:(NSObject *)value atPath:(NSString *)path schema:(NSDictionary *)schema definitions:(NSDictionary *)definitions
{
    
    NSString *type = schema[@"type"];
    if(type){
        NSMutableArray *errors = [NSMutableArray array];
        if([type isEqualToString:@"object"]){
            [errors addObjectsFromArray:[self validateObject:value atPath:path schema:schema definitions:definitions]];
        } else if([type isEqualToString:@"array"]){
            [errors addObjectsFromArray:[self validateArray:value atPath:path withSchema:schema definitions:definitions]];
        } else if([type isEqualToString:@"string"]){
            NSError *error = [self validateString:value atPath:path withSchema:schema];
            if(error){
                [errors addObject:error];
            }
        } else if([type isEqualToString:@"number"]){
            NSError *error = [self validateNumber:value atPath:path withSchema:schema];
            if(error){
                [errors addObject:error];
            }
        } else {
            [errors addObject:[self errorWithMessage:[NSString stringWithFormat:@"%@ is of unsupported type at %@", type, path]]];
        }
        return errors;
    }
    
    NSString *ref = schema[@"$ref"];
    if(ref){
        //This is not complete, as resolution is more complex
        NSString *entry;
        if([ref hasPrefix:@"#/definitions/"]){
            entry = [ref stringByReplacingOccurrencesOfString:@"#/definitions/" withString:@""];
        } else if([ref hasPrefix:@"#"]){
            entry = @"#";
        }
        return [self validate:value atPath:path schema:definitions[entry] definitions:definitions];
    }
    return @[];
}

- (NSArray *)validateObject:(NSObject *)value atPath:(NSString *)path schema:(NSDictionary *)schema definitions:(NSDictionary *)definitions
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
            [errors addObjectsFromArray:[self validate:obj[property] atPath:newPath schema:properties[property] definitions:definitions]];
        }
    }
    
    NSArray *required = schema[@"required"];
    NSSet *requiredSet = [NSSet setWithArray:required];
    NSSet *valuesSet = [NSSet setWithArray:obj.allKeys];
    NSMutableSet *missingSet = [requiredSet mutableCopy];
    [missingSet minusSet:valuesSet];
    
    if(required && missingSet.count > 0){
        [errors addObject:[self errorWithMessage:[NSString stringWithFormat:@"%@ is missing properties %@ which are required", path, missingSet]]];
    }
    
    return errors;
}

- (NSArray *)validateArray:(NSObject *)value atPath:(NSString *)path withSchema:(NSDictionary *)schema definitions:(NSDictionary *)definitions
{
    if(![value isKindOfClass:NSArray.class]){
        return @[[self errorWithMessage:[NSString stringWithFormat:@"%@ is not a array", path]]];
    }
    NSArray *arr = (NSArray *)value;
    
    NSMutableArray *errors = [NSMutableArray new];
    NSObject *items = schema[@"items"];
    
    if([items isKindOfClass:NSDictionary.class]){
        for(NSInteger i = 0; i < arr.count; i++){
            [errors addObjectsFromArray:[self validate:arr[i] atPath:[NSString stringWithFormat:@"%@[%i]", path, i] schema:(NSDictionary *)items definitions:definitions]];
        }
    } else if([items isKindOfClass:NSArray.class]) {
        NSArray *itemsArray = (NSArray *)items;
        for(NSInteger i = 0; i < itemsArray.count && i < arr.count; i++){
            [errors addObjectsFromArray:[self validate:arr[i] atPath:[NSString stringWithFormat:@"%@[%i]", path, i] schema:itemsArray[i] definitions:definitions]];
        }
        
        NSNumber *additionalItems = schema[@"additionalItems"];
        if(additionalItems && ![additionalItems boolValue] && arr.count > itemsArray.count){
            NSError *error = [self errorWithMessage:[NSString stringWithFormat:@"%@ should not have additional entries have %i, should have %i", path, arr.count, itemsArray.count]];
            [errors addObject:error];
        }
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
    
    NSString *pattern = schema[@"pattern"];
    if(pattern){
        NSError *error;
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
        
        NSUInteger matches =[reg numberOfMatchesInString:str options:0 range:NSMakeRange(0, str.length)];
        if(!matches){
            return [self errorWithMessage:[NSString stringWithFormat:@"%@ does not match %@", path, pattern]];
        }
    }

    return nil;
}

- (NSError *)validateNumber:(NSObject *)value atPath:(NSString *)path withSchema:(NSDictionary *)schema
{
    if(![value isKindOfClass:NSNumber.class]){
        return [self errorWithMessage:[NSString stringWithFormat:@"%@ is not a number", path]];
    }
    NSNumber *number = (NSNumber *)value;
    NSNumber *maximum = schema[@"maximum"];
    if(maximum && [number compare:maximum] == NSOrderedDescending){
        return [self errorWithMessage:[NSString stringWithFormat:@"%@ is is greater then %@", path, [maximum stringValue]]];
    }

    NSNumber *minimum = schema[@"minimum"];
    if(minimum && [number compare:minimum] == NSOrderedAscending){
        return [self errorWithMessage:[NSString stringWithFormat:@"%@ is is less then %@", path, [maximum stringValue]]];
    }

    return nil;
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
        str = [NSString stringWithFormat:@"%@\n%@", str, error.userInfo[@"message"]];
    }
    
    return str;
}
@end