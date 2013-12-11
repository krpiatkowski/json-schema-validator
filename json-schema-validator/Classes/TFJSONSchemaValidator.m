 //
//  TFJSONSchemaValidator.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 04/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import "TFJSONSchemaValidator.h"

typedef enum  {
    TFJSONSchemaValidatorArray,
    TFJSONSchemaValidatorBoolean,
    TFJSONSchemaValidatorInteger,
    TFJSONSchemaValidatorNumber,
    TFJSONSchemaValidatorNull,
    TFJSONSchemaValidatorObject,
    TFJSONSchemaValidatorString,
    TFJSONSchemaValidatorUnknown
} TFJSONSchemaValidatorType;

static NSString *kJSONSchemaValidationDomain = @"JSON Validation";
static NSString *kJSONSchemaValidationPathDelimiter = @"->";

@implementation TFJSONSchemaValidator{
    NSBundle *_bundle;
}

+ (TFJSONSchemaValidator *)validator
{
    return [[TFJSONSchemaValidator alloc] initWithBundle:[NSBundle mainBundle]];
}

- (id)initWithBundle:(NSBundle *)bundle
{
    self = [super init];
    if (self) {
        _bundle = bundle;
    }
    return self;
}

- (NSError *)validate:(NSDictionary *)jsonObject withSchemaPath:(NSString *)path
{
    NSError *error;
    NSDictionary *schema = [self loadSchemaFromPath:path error:error];
    if(error){
        return error;
    }
    return [self validate:jsonObject withSchema:schema];
}

- (NSDictionary *)loadSchemaFromPath:(NSString *)path error:(NSError *)error
{
    NSString *realPath = [_bundle pathForResource:path ofType:@"json"];
    return [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:realPath] options:0 error: &error];
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
    
    NSArray *errors = [self validate:jsonObject atPath:@"#" schema:schema definitions:definitions];
    
    if(errors.count > 0){
        return [NSError errorWithDomain:kJSONSchemaValidationDomain code:1 userInfo:@{@"message" : @"Validation failed", @"errors" : errors}];
    }
    return nil;
}


- (NSArray *)validate:(NSObject *)value atPath:(NSString *)path schema:(NSDictionary *)schema definitions:(NSMutableDictionary *)definitions
{
    if(schema[@"type"]){
        NSString *type = schema[@"type"];
        TFJSONSchemaValidatorType t = [self stringToType:type];
        NSError *typeError = [self validateType:value expect:t atPath:path];
        if(typeError){
            return @[typeError];
        }

        NSMutableArray *errors = [NSMutableArray array];
        
        switch (t) {
            case TFJSONSchemaValidatorArray:{
                [errors addObjectsFromArray:[self validateArray:value atPath:path withSchema:schema definitions:definitions]];
                break;
            }
            case TFJSONSchemaValidatorObject:{
                [errors addObjectsFromArray:[self validateObject:value atPath:path schema:schema definitions:definitions]];
                break;
            }
            case TFJSONSchemaValidatorBoolean:
            case TFJSONSchemaValidatorNumber:
            case TFJSONSchemaValidatorInteger:{
                NSError *error = [self validateNumberic:value atPath:path withSchema:schema];
                if(error){
                    [errors addObject:error];
                }
                break;
            }
            case TFJSONSchemaValidatorString:{
                NSError *error = [self validateString:value atPath:path withSchema:schema];
                if(error){
                    [errors addObject:error];
                }
                break;
            }
            case TFJSONSchemaValidatorNull:{
                //If we dont have a type mismatch null is fine :)
                break;
            }
            case TFJSONSchemaValidatorUnknown:{
                [errors addObject:[self errorWithMessage:[NSString stringWithFormat:@"%@ is of unsupported type at %@", type, path]]];
                break;
            }
        }
        
        if(schema[@"allOf"]){
            NSArray *allOfArr = schema[@"allOf"];
            NSArray *errs = [self validateObject:value withSet:allOfArr atPath:path pathPrefix:@"allOf" definitions:definitions];
            if(errs.count != 0){
                for(NSArray *e in errs){
                    [errors addObjectsFromArray:e];
                }
            }
        }
        
        if(schema[@"anyOf"]){
            NSArray *anyOfArr = schema[@"anyOf"];
            NSArray *errs = [self validateObject:value withSet:anyOfArr atPath:path pathPrefix:@"anyOf" definitions:definitions];
            if(errs.count == anyOfArr.count){
                for(NSArray *e in errs){
                    [errors addObjectsFromArray:e];
                }
            }
        }
        
        if(schema[@"oneOf"]){
            NSArray *oneOfArr = schema[@"oneOf"];
            NSArray *errs = [self validateObject:value withSet:oneOfArr atPath:path pathPrefix:@"oneOf" definitions:definitions];
            if(errs.count-1 != oneOfArr.count){
                for(NSArray *e in errs){
                    [errors addObjectsFromArray:e];
                }
            }
        }
        
        return errors;
    } else if(schema[@"$ref"]) {
        NSString *ref = schema[@"$ref"];

        //This is not complete, as resolution is more complex
        NSString *entry;
        if([ref hasPrefix:@"#/definitions/"]){
            entry = [ref stringByReplacingOccurrencesOfString:@"#/definitions/" withString:@""];
        } else if([ref hasPrefix:@"#"]){
            entry = @"#";
        } else if([ref hasPrefix:@"bundle://"]){
            if(!_bundle){
                return @[[self errorWithMessage:@"Bundle not set, bundle:// not supported when schema from dictionary"]];
            }
            
            entry = [ref stringByReplacingOccurrencesOfString:@"bundle://" withString:@""];
            entry = [entry stringByReplacingOccurrencesOfString:@".json" withString:@""];
            
            NSError *error;
            NSDictionary *schema = [self loadSchemaFromPath:entry error:error];
            if(error){
                return @[error];
            }
            
            definitions[ref] = schema;
            entry = ref;
        }
        return [self validate:value atPath:path schema:definitions[entry] definitions:definitions];
    } else {
        return @[[self errorWithMessage:[NSString stringWithFormat:@"Schema is missing type or $ref for path %@", path]]];
    }
}


- (NSArray *)validateObject:(NSObject *)value withSet:(NSArray *)set atPath:(NSString *)path pathPrefix:(NSString *)pathPrefix definitions:(NSMutableDictionary *)definitions
{
    NSMutableArray *errors = [NSMutableArray new];
    for(NSInteger i = 0; i < set.count; i++){
        NSString *newPath = [NSString stringWithFormat:@"%@@%@[%i]", path, pathPrefix, i];
        NSArray *error = [self validate:value atPath:newPath schema:set[i] definitions:definitions];
        if(error.count > 0){
            [errors addObject:error];
        }
    }
    return errors;
}

- (NSArray *)validateObject:(NSObject *)value atPath:(NSString *)path schema:(NSDictionary *)schema definitions:(NSMutableDictionary *)definitions
{
    NSDictionary *obj = (NSDictionary *)value;
    
    NSMutableArray *errors = [NSMutableArray new];
    NSDictionary *properties = schema[@"properties"];
    for(NSString *property in properties){
        NSString *newPath = [NSString stringWithFormat:@"%@%@%@", path, kJSONSchemaValidationPathDelimiter, property];
        if(obj[property] && properties[property]){
            [errors addObjectsFromArray:[self validate:obj[property] atPath:newPath schema:properties[property] definitions:definitions]];
        }
    }
    
    
    NSDictionary *patternProperties = schema[@"patternProperties"];
    for(NSString *property in patternProperties){
        NSError *error;
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:property options:0 error:&error];

        for(NSString *objKey in obj.allKeys){
            if(!properties[objKey]){
                if([reg numberOfMatchesInString:objKey options:0 range:NSMakeRange(0, objKey.length)]){
                    NSString *newPath = [NSString stringWithFormat:@"%@%@%@", path, kJSONSchemaValidationPathDelimiter, objKey];
                    [errors addObjectsFromArray:[self validate:obj[objKey] atPath:newPath schema:patternProperties[property] definitions:definitions]];
                }
            }
        }
    }
    
    
    NSArray *required = schema[@"required"];
    NSSet *requiredSet = [NSSet setWithArray:required];
    NSSet *valuesSet = [NSSet setWithArray:obj.allKeys];
    NSMutableSet *missingSet = [requiredSet mutableCopy];
    [missingSet minusSet:valuesSet];
    
    if(required && missingSet.count > 0){
        NSString *msg;
        if(missingSet.count > 1){
            msg = @"%@ is missing properties (%@) which are required";
        } else {
            msg = @"%@ is missing property (%@) which is required";
        }
        [errors addObject:[self errorWithMessage:[NSString stringWithFormat:msg, path, [[missingSet allObjects] componentsJoinedByString:@","]]]];
    }
    
    return errors;
}

- (NSArray *)validateArray:(NSObject *)value atPath:(NSString *)path withSchema:(NSDictionary *)schema definitions:(NSMutableDictionary *)definitions
{
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
    
    NSNumber *minItems = schema[@"minItems"];
    if(minItems && arr.count < [minItems integerValue]){
        [errors addObject:[self errorWithMessage:[NSString stringWithFormat:@"%@ must have a minimum of %i items, it has %i", path, [minItems integerValue], arr.count]]];
    }

    NSNumber *maxItems = schema[@"maxItems"];
    if(maxItems && arr.count > [maxItems integerValue] ){
        [errors addObject:[self errorWithMessage:[NSString stringWithFormat:@"%@ must have a maximum of %i items, it has %i", path, [maxItems integerValue], arr.count]]];
    }

    return errors;
}

- (NSError *)validateString:(NSObject *)value atPath:(NSString *)path withSchema:(NSDictionary *)schema
{
    NSString *str = (NSString *)value;
    
    if(schema[@"format"]){
        NSString *format = schema[@"format"];
        NSError *error = nil;
        if([format isEqualToString:@"regex"]){
            [NSRegularExpression regularExpressionWithPattern:str options:0 error:&error];
            if(error){
                return [self errorWithMessage:[NSString stringWithFormat:@"%@ is not a valid regex (%@)", str, str]];
            }
        }
    }
    
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

- (NSError *)validateNumberic:(NSObject *)value atPath:(NSString *)path withSchema:(NSDictionary *)schema
{
    NSNumber *number = (NSNumber *)value;
    
    NSNumber *maximum = schema[@"maximum"];
    if(maximum && [number compare:maximum] == NSOrderedDescending){
        return [self errorWithMessage:[NSString stringWithFormat:@"%@ is is greater then %@", path, [maximum stringValue]]];
    }

    NSNumber *minimum = schema[@"minimum"];
    if(minimum && [number compare:minimum] == NSOrderedAscending){
        return [self errorWithMessage:[NSString stringWithFormat:@"%@ is is less then %@", path, [minimum stringValue]]];
    }

    return nil;
}

- (NSError *)validateType:(NSObject *)value expect:(TFJSONSchemaValidatorType)expect atPath:(NSString *)path
{
    TFJSONSchemaValidatorType valueType;
    if([value isKindOfClass:NSString.class]){
        valueType = TFJSONSchemaValidatorString;
    } else if([value isKindOfClass:NSDictionary.class]){
        valueType = TFJSONSchemaValidatorObject;
    } else if ([value isKindOfClass:NSArray.class]){
        valueType = TFJSONSchemaValidatorArray;
    } else if([value isKindOfClass:NSNumber.class]){
        NSNumber *number = (NSNumber *)value;
        BOOL isInteger = (strcmp([number objCType], @encode(NSInteger))) == 0 ||
                         (strcmp([number objCType], @encode(int)))       == 0 ||
                         (strcmp([number objCType], @encode(long)))      == 0 ||
                         (strcmp([number objCType], @encode(long long))) == 0;
        
        if(isInteger){
            valueType = TFJSONSchemaValidatorInteger;
        } else if(strcmp([number objCType], @encode(char)) == 0){
            //Bools are chars
            valueType = TFJSONSchemaValidatorBoolean;
        } else {
            valueType = TFJSONSchemaValidatorNumber;
        }
        
        //if we expect a numeric and we get an integer, we can live with that.
        if(valueType == TFJSONSchemaValidatorInteger && expect == TFJSONSchemaValidatorNumber){
            valueType = TFJSONSchemaValidatorNumber;
        }
        
    } else if([value isKindOfClass:NSNull.class]){
        valueType = TFJSONSchemaValidatorNull;
    } else {
        valueType = TFJSONSchemaValidatorUnknown;
    }
    
    if(valueType != expect){
        return [self errorWithMessage:[NSString stringWithFormat:@"%@ is a \"%@\" expected a \"%@\"", path, [self typeToString:valueType], [self typeToString:expect]]];
    } else {
        return nil;
    }
}

- (TFJSONSchemaValidatorType)stringToType:(NSString *)type
{
    if([type isEqualToString:@"array"]){
        return TFJSONSchemaValidatorArray;
    } else if([type isEqualToString:@"boolean"]){
        return TFJSONSchemaValidatorBoolean;
    } else if([type isEqualToString:@"integer"]){
        return TFJSONSchemaValidatorInteger;
    } else if([type isEqualToString:@"number"]){
        return TFJSONSchemaValidatorNumber;
    } else if([type isEqualToString:@"null"]){
        return TFJSONSchemaValidatorNull;
    } else if([type isEqualToString:@"object"]){
        return TFJSONSchemaValidatorObject;
    } else if([type isEqualToString:@"string"]){
        return TFJSONSchemaValidatorString;
    } else {
        return TFJSONSchemaValidatorUnknown;
    }
}

- (NSString *)typeToString:(TFJSONSchemaValidatorType)type
{
    switch (type) {
        case TFJSONSchemaValidatorArray:
            return @"array";
        case TFJSONSchemaValidatorObject:
            return @"object";
        case TFJSONSchemaValidatorString:
            return @"string";
        case TFJSONSchemaValidatorNull:
            return @"null";
        case TFJSONSchemaValidatorBoolean:
            return @"boolean";
        case TFJSONSchemaValidatorInteger:
            return @"integer";
        case TFJSONSchemaValidatorNumber:
            return @"number";
        case TFJSONSchemaValidatorUnknown:
            return @"unknown";
    }
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
    NSString *str = @"";
    if(!errors.userInfo[@"errors"]){
        str = [errors description];
    } else {
        for(NSError *error in errors.userInfo[@"errors"]){
            str = [NSString stringWithFormat:@"%@%@\n", str, error.userInfo[@"message"]];
        }
    }
    return str;
}
@end