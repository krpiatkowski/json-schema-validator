//
//  TFJSONSchemaValidatorAbstractTests.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 06/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import "TFJSONSchemaValidatorAbstractTests.h"
#import "TFJSONSchemaValidator.h"

@implementation TFJSONSchemaValidatorAbstractTests{
}
- (NSString *)schema
{
    NSAssert(NO, @"Override in subclass");
    return @"";
}

static TFJSONSchemaValidator *_validator;

- (void)setUp
{
    if(!_validator){
        _validator = [[TFJSONSchemaValidator alloc] initWithBundle:[NSBundle bundleForClass:[self class]]];
        [_validator loadSchemas];
    }
}


- (BOOL)assertOk:(NSDictionary *)json
{
    NSError *error = [_validator validate:json withSchema:[self schema]];
    NSLog(@"%@", [self prettyPrintErrors:error]);
    return !error;
}

- (BOOL)assertFail:(NSDictionary *)json
{
    NSError *error = [_validator validate:json withSchema:[self schema]];
    if(error == nil){
        NSLog(@"Validation ok, should fail");
    }
    return error != nil;
}

- (BOOL)assertOKWithSchema:(NSString *)schema data:(NSString *)data
{
    NSString *dataPath = [[NSBundle bundleForClass:[self class]] pathForResource:data ofType:@"json"];
    NSData *d = [NSData dataWithContentsOfFile:dataPath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
    NSError *error = [_validator validate:json withSchema:schema];
    NSLog(@"%@", [self prettyPrintErrors:error]);
    return !error;
}

- (BOOL)assertFailWithSchema:(NSString *)schema data:(NSString *)data
{
    NSString *dataPath = [[NSBundle bundleForClass:[self class]] pathForResource:data ofType:@"json"];
    NSData *d = [NSData dataWithContentsOfFile:dataPath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
    NSError *error = [_validator validate:json withSchema:schema];
    if(error == nil){
        NSLog(@"Validation ok, should fail");
    }
    return error != nil;
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
            str = [NSString stringWithFormat:@"%@%@\n", str, error.userInfo[NSLocalizedDescriptionKey]];
        }
    }
    return str;
}

@end
