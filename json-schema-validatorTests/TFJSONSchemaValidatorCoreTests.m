//
//  TFJSONSchemaValidatorCoreTests.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 04/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TFJSONSchemaValidator.h"
#import "TFJSONSchemaValidatorAbstractTests.h"

@interface TFJSONSchemaValidatorCoreTests : TFJSONSchemaValidatorAbstractTests

@end

@interface TFJSONSchemaValidator (private)
- (NSError *)validate:(NSDictionary *)jsonObject withSchema:(NSDictionary *)schema;
@end

@implementation TFJSONSchemaValidatorCoreTests

- (NSString *)schema
{
    return @"TFJSONSchemaValidatorCoreTests";
}

- (void)testWrongSchema
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{} withSchema:@"Wrong"];
    XCTAssertNotNil(error, @"Schema exist");
}

- (void)testEmptyJSONPass
{
    [self assertOk:@{}];
}

- (void)testMinimumSchemaPass
{
    [self assertOk:@{@"test" : @(1)}];
}

- (void)testInvalidSchemaFail
{
    BOOL status = [self assertFailWithSchema:@"TFJSONSchemaValidatorCoreInvalidSchema" data:@"TFJSONSchemaValidatorCoreInvalidSchemaData"];
    XCTAssert(status);
}

- (void)testLoadFromBundle
{
    [[[TFJSONSchemaValidator alloc] initWithBundle:[NSBundle bundleForClass:[self class]]] loadSchemas];
}
@end