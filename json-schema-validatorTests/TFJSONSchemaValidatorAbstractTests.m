//
//  TFJSONSchemaValidatorAbstractTests.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 06/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import "TFJSONSchemaValidatorAbstractTests.h"
#import "TFJSONSchemaValidator.h"

@implementation TFJSONSchemaValidatorAbstractTests
- (NSString *)schema
{
    NSAssert(NO, @"Override in subclass");
    return @"";
}

- (BOOL)assertOk:(NSDictionary *)json
{
    NSError *error = [[[TFJSONSchemaValidator alloc] initWithBundle:[NSBundle bundleForClass:[self class]]] validate:json withSchemaPath:[self schema]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    return !error;
}

- (BOOL)assertFail:(NSDictionary *)json
{
    NSError *error = [[[TFJSONSchemaValidator alloc] initWithBundle:[NSBundle bundleForClass:[self class]]] validate:json withSchemaPath:[self schema]];
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
    NSError *error = [[[TFJSONSchemaValidator alloc] initWithBundle:[NSBundle bundleForClass:[self class]]] validate:json withSchemaPath:schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    return !error;
}

- (BOOL)assertFailWithSchema:(NSString *)schema data:(NSString *)data
{
    NSString *dataPath = [[NSBundle bundleForClass:[self class]] pathForResource:data ofType:@"json"];
    NSData *d = [NSData dataWithContentsOfFile:dataPath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
    NSError *error = [[[TFJSONSchemaValidator alloc] initWithBundle:[NSBundle bundleForClass:[self class]]] validate:json withSchemaPath:schema];
    if(error == nil){
        NSLog(@"Validation ok, should fail");
    }
    return error != nil;
}
@end