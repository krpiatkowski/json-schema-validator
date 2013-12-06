//
//  TFJSONSchemaValidatorNumberTests.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 04/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TFJSONSchemaValidatorAbstractTests.h"
#import "TFJSONSchemaValidator.h"

@interface TFJSONSchemaValidatorNumberTests : TFJSONSchemaValidatorAbstractTests

@end

@implementation TFJSONSchemaValidatorNumberTests
- (NSString *)schema
{
    return @"TFJSONSchemaValidatorNumberTests";
}

- (void)testNumberValidation
{
    BOOL status = [self assertOk:@{@"testProp" : @(200)}];
    XCTAssert(status);
}

- (void)testNumberMaximumFailed
{
    BOOL status = [self assertFail:@{@"testProp" : @(9999)}];
    XCTAssert(status);
}

- (void)testNumberMinimumFailed
{
    BOOL status = [self assertFail:@{@"testProp" : @(0)}];
    XCTAssert(status);
}

- (void)testNumberMaximumFloatFailed
{
    BOOL status = [self assertFail:@{@"testProp" : @(9999.9)}];
    XCTAssert(status);
}

- (void)testNumberMinimumFloatFailed
{
    BOOL status = [self assertFail:@{@"testProp" : @(9.9)}];
    XCTAssert(status);
}

- (void)testNumberNegative
{
    BOOL status = [self assertOk:@{@"testPropNegative" : @(-199)}];
    XCTAssert(status);
}
@end