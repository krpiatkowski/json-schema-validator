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

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testNilSchema
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{} withSchema:nil];
    
    XCTAssertNotNil(error, @"Schema must not be nil");
}

- (void)testEmptyJSONPass
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{} withSchema:@{@"type" : @"object"}];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"Empty json is always valid");
}

- (void)testMinimumSchemaPass
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"test" : @(1)} withSchema:@{@"type" : @"object"}];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"Empty schema is always valid");
}
- (void)testInvalidSchemaFail
{
    BOOL status = [self assertFailWithSchema:@"TFJSONSchemaValidatorCoreInvalidSchema" data:@"TFJSONSchemaValidatorCoreInvalidSchemaData"];
    XCTAssert(status);
}
@end