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

@interface TFJSONSchemaWrapper : NSObject{
    @public
    NSDictionary *schema;
    NSError *error;
}
@end

@implementation TFJSONSchemaWrapper
@end

@implementation TFJSONSchemaValidator{
    NSBundle *_bundle;
    NSDictionary *_validatorSchema;
    BOOL _loaded;
    NSMutableDictionary *_schemas;
    NSMutableDictionary *_regularExpressions;
}

+ (TFJSONSchemaValidator *)validator
{
    static TFJSONSchemaValidator *validator;
    if(!validator){
        validator = [[TFJSONSchemaValidator alloc] initWithBundle:[NSBundle mainBundle]];
    }
    return validator;
}

- (id)initWithBundle:(NSBundle *)bundle
{
    self = [super init];
    if (self) {
        _bundle = bundle;
        _schemas = [NSMutableDictionary new];
        _regularExpressions = [NSMutableDictionary new];

        NSString *path = [_bundle pathForResource:@"validator_schema" ofType:@"json"];
        if(!path){
            [[NSException exceptionWithName:@"Validator scheme missing" reason:@"We should always be able to find the validator_schema.json!" userInfo:nil] raise];
        }

        NSError *error;
        _validatorSchema = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:&error];
        if(error){
            [[NSException exceptionWithName:@"Validator scheme invalid" reason:@"Validator_schema should be valid!" userInfo:@{@"error" : error}] raise];
        }
    }
    return self;
}


- (NSInteger)loadSchemas:(BOOL)validate
{
    if(_loaded) return _schemas.count;
    NSArray *schemaPaths = [_bundle pathsForResourcesOfType:@"schema.json" inDirectory:@""];

    NSLog(@"Loading schemas in bundle");
    for(NSString *schemaPath in schemaPaths){
        NSString *schemaName = [[schemaPath componentsSeparatedByString:@"/"] lastObject];
        schemaName = [[schemaName componentsSeparatedByString:@".schema.json"] firstObject];
        
        TFJSONSchemaWrapper *wrapper = [self loadSchemaFromPath:schemaPath];
        if(wrapper->error){
            NSLog(@"Failed to load schema:%@\n%@", schemaName, wrapper->error.userInfo[NSLocalizedDescriptionKey]);
        } else {
            
            NSError *error = nil;
            if(validate){
                error = [self validate:wrapper->schema withSchemaObject:_validatorSchema];
            }
            if(error){
                NSLog(@"Failed to validate schema:%@", schemaName);
                for(NSError *err in error.userInfo[@"errors"]){
                    NSLog(@"%@", err.userInfo[NSLocalizedDescriptionKey]);
                }
            } else {
                _schemas[schemaName] = wrapper->schema;
                NSLog(@"Loaded schema:%@", schemaName);
            }
        }
    }
    
    _loaded = YES;
    return _schemas.count;
}


- (NSError *)validate:(NSDictionary *)jsonObject withSchema:(NSString *)name
{
    if(_schemas[name]){
        return [self validate:jsonObject withSchemaObject:_schemas[name]];
    } else {
        return [self errorWithMessage:[NSString stringWithFormat:@"Invalid schema name:%@", name]];
    }
}

- (TFJSONSchemaWrapper *)loadSchemaFromPath:(NSString *)path
{
    TFJSONSchemaWrapper *wrapper = [TFJSONSchemaWrapper new];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *schema = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if(error){
        wrapper->error = error;
        return wrapper;
    }
    
    wrapper->schema = schema;
    return wrapper;
}

- (NSError *)validate:(NSDictionary *)jsonObject withSchemaObject:(NSDictionary *)schema
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
        return [NSError errorWithDomain:kJSONSchemaValidationDomain code:1 userInfo:@{NSLocalizedDescriptionKey : @"Validation failed", @"errors" : errors}];
    }
    return nil;
}


- (NSArray *)validate:(NSObject *)value atPath:(NSString *)path schema:(NSDictionary *)schema definitions:(NSMutableDictionary *)definitions
{
    
    if(![schema isKindOfClass:[NSDictionary class]]){
        return @[[self errorWithMessage:[NSString stringWithFormat:@"schema-error:%@ must be a schema", path]]];
    }
    
    NSArray *schemaTypes = @[@"type", @"allOf", @"anyOf", @"oneOf", @"$ref", @"enum"];
    BOOL found = NO;
    for(NSString *type in schemaTypes){
        if(schema[type]){
            if(found){
                return @[[self errorWithMessage:[NSString stringWithFormat:@"schema-error:%@ must only have of of the following properties [%@]", path, [schemaTypes componentsJoinedByString:@","]]]];
            }
            found = YES;
        }
    }
    
    
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
        return errors;
    } else if(schema[@"allOf"]){
        NSArray *allOfArr = schema[@"allOf"];
        NSMutableArray *errors = [NSMutableArray array];

        NSArray *validationErrors = [self validateObject:value withSet:allOfArr atPath:path pathPrefix:@"allOf" definitions:definitions];
        if(validationErrors.count != 0){
            [errors addObject:[self errorWithMessage:[NSString stringWithFormat:@"%@ does not match \"allOf\"", path]]];
            for(NSArray *e in validationErrors){
                [errors addObjectsFromArray:e];
            }
        }
        return errors;
    } else if(schema[@"anyOf"]){
        NSArray *anyOfArr = schema[@"anyOf"];
        NSMutableArray *errors = [NSMutableArray array];

        NSArray *validationErrors = [self validateObject:value withSet:anyOfArr atPath:path pathPrefix:@"anyOf" definitions:definitions];
        if(validationErrors.count == anyOfArr.count){
            [errors addObject:[self errorWithMessage:[NSString stringWithFormat:@"%@ does not match \"anyOf\"", path]]];
            for(NSArray *e in validationErrors){
                [errors addObjectsFromArray:e];
            }
        }
        return errors;
    } else if(schema[@"oneOf"]){
        NSArray *oneOfArr = schema[@"oneOf"];
        NSMutableArray *errors = [NSMutableArray array];

        NSMutableArray *matches = [NSMutableArray array];
        NSMutableArray *validationErrors = [NSMutableArray array];
        
        for(NSInteger i = 0; i < oneOfArr.count; i++){
            NSString *newPath = [NSString stringWithFormat:@"%@@oneOf[%i]", path, i];
            NSArray *error = [self validate:value atPath:newPath schema:oneOfArr[i] definitions:definitions];
            if(error.count == 0){
                [matches addObject:@(i)];
            } else {
                [validationErrors addObject:error];
            }
        }
        
        if(matches.count != 1){
            NSString *matchesStr = matches.count > 0 ? [NSString stringWithFormat:@", matches [%@]", [matches componentsJoinedByString:@","]] : @"";
            [errors addObject:[self errorWithMessage:[NSString stringWithFormat:@"%@ does not match \"oneOf\"%@", path, matchesStr]]];
            for(NSArray *e in validationErrors){
                [errors addObjectsFromArray:e];
            }
        }
        return errors;
    } else if(schema[@"$ref"]) {
        NSString *ref = schema[@"$ref"];
        NSMutableArray *errors = [NSMutableArray array];

        
        //This is not complete, as resolution is more complex
        NSDictionary *schema;
        if([ref hasPrefix:@"#/definitions/"]){
           NSString *entry = [ref stringByReplacingOccurrencesOfString:@"#/definitions/" withString:@""];
            schema = definitions[entry];
        } else if([ref hasPrefix:@"#"]){
           NSString *entry = @"#";
            schema = definitions[entry];
        } else if([ref hasPrefix:@"bundle://"] && !definitions[ref]){
            NSString *bundlePath = [ref stringByReplacingOccurrencesOfString:@"bundle://" withString:@""];
            schema = _schemas[bundlePath];
        }
        
        if(!schema){
            [errors addObject:[self errorWithMessage:[NSString stringWithFormat:@"schema-error:%@ has a invalid reference %@",path, ref]]];
        } else {
            NSMutableString *newPath = [NSMutableString stringWithString:path];
            [newPath appendString:kJSONSchemaValidationPathDelimiter];
            [newPath appendString:@"{"];
            [newPath appendString:ref];
            [newPath appendString:@"}"];
            [errors addObjectsFromArray:[self validate:value atPath:newPath schema:schema definitions:schema[@"definitions"]]];
        }
        return errors;
    } else if(schema[@"enum"]){
        NSArray *enums = schema[@"enum"];
        NSMutableArray *errors = [NSMutableArray array];

        NSSet *enumsSet = [NSSet setWithArray:enums];
        if(enums.count > enumsSet.count){
            [errors addObject:[self errorWithMessage:[NSString stringWithFormat:@"%@ is an enum and is not unique [%@]", path, [enums componentsJoinedByString:@","]]]];
        } else if(![enums containsObject:value]){
            [errors addObject:[self errorWithMessage:[NSString stringWithFormat:@"%@ (%@) is not a valid enum-item [%@]", path, value, [enums componentsJoinedByString:@","]]]];
        }
        return errors;
    } else {
        return @[[self errorWithMessage:[NSString stringWithFormat:@"schema-error:%@ must have a [%@] property", path, [schemaTypes componentsJoinedByString:@","]]]];
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
        //Faster then stringWithFormat
        NSMutableString *newPath = [NSMutableString stringWithString:path];
        [newPath appendString:kJSONSchemaValidationPathDelimiter];
        [newPath appendString:property];
        
        if(obj[property] && properties[property]){
            [errors addObjectsFromArray:[self validate:obj[property] atPath:newPath schema:properties[property] definitions:definitions]];
        }
    }
    
    
    NSDictionary *patternProperties = schema[@"patternProperties"];
    for(NSString *property in patternProperties){
        
        NSError *error;
        NSRegularExpression *reg = _regularExpressions[property];
        if(!reg){
            reg = [NSRegularExpression regularExpressionWithPattern:property options:0 error:&error];
            _regularExpressions[property] = reg;
        }
        
        for(NSString *objKey in obj.allKeys){
            if(!properties[objKey]){
                if([reg numberOfMatchesInString:objKey options:0 range:NSMakeRange(0, objKey.length)]){
                    NSMutableString *newPath = [NSMutableString stringWithString:path];
                    [newPath appendString:kJSONSchemaValidationPathDelimiter];
                    [newPath appendString:property];
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
        NSRegularExpression *reg = _regularExpressions[pattern];
        if(!reg){
            reg = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
            _regularExpressions[pattern] = reg;
        }
        
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

        CFNumberType type = CFNumberGetType((CFNumberRef)number);
        
        BOOL isInteger = type == kCFNumberNSIntegerType ||
                         type == kCFNumberIntType ||
                         type == kCFNumberLongType ||
                         type == kCFNumberLongLongType;
        
        if(isInteger){
            valueType = TFJSONSchemaValidatorInteger;
        } else if(type == kCFNumberCharType){
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

static NSString *kArrayStr = @"array";
static NSString *kBoolStr = @"boolean";
static NSString *kIntegerStr = @"integer";
static NSString *kNumberStr = @"number";
static NSString *kNullStr = @"null";
static NSString *kObjectStr = @"object";
static NSString *kStringStr = @"string";
static NSString *kUnknownStr = @"unknown";

- (TFJSONSchemaValidatorType)stringToType:(NSString *)type
{
    if([type isEqualToString:kObjectStr]){
        return TFJSONSchemaValidatorObject;
    } else if([type isEqualToString:kStringStr]){
        return TFJSONSchemaValidatorString;
    } else if([type isEqualToString:kIntegerStr]){
        return TFJSONSchemaValidatorInteger;
    } else if([type isEqualToString:kArrayStr]){
        return TFJSONSchemaValidatorArray;
    } else if([type isEqualToString:kNumberStr]){
        return TFJSONSchemaValidatorNumber;
    } else if([type isEqualToString:kBoolStr]){
        return TFJSONSchemaValidatorBoolean;
    } else if([type isEqualToString:kNullStr]){
        return TFJSONSchemaValidatorNull;
    } else {
        return TFJSONSchemaValidatorUnknown;
    }
}

- (NSString *)typeToString:(TFJSONSchemaValidatorType)type
{
    switch (type) {
        case TFJSONSchemaValidatorArray:
            return kArrayStr;
        case TFJSONSchemaValidatorObject:
            return kObjectStr;
        case TFJSONSchemaValidatorString:
            return kStringStr;
        case TFJSONSchemaValidatorNull:
            return kNullStr;
        case TFJSONSchemaValidatorBoolean:
            return kBoolStr;
        case TFJSONSchemaValidatorInteger:
            return kIntegerStr;
        case TFJSONSchemaValidatorNumber:
            return kNullStr;
        case TFJSONSchemaValidatorUnknown:
            return kUnknownStr;
    }
}

- (NSError *)errorWithMessage:(NSString *)message
{
    return [NSError errorWithDomain:kJSONSchemaValidationDomain code:0 userInfo:@{NSLocalizedDescriptionKey : message}];
}
@end