//
//  TFJSONSchemaValidatorSimpleValidations.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 04/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TFJSONSchemaValidatorAbstractTests.h"
#import "TFJSONSchemaValidator.h"

@interface TFJSONSchemaValidatorStringTests : TFJSONSchemaValidatorAbstractTests

@end

@implementation TFJSONSchemaValidatorStringTests
- (NSString *)schema
{
    return @"TFJSONSchemaValidatorStringTests";
}

- (void)testStringValidation
{
    BOOL status = [self assertOk:@{@"testProp" : @"test"}];
    XCTAssert(status);
}

- (void)testStringValidationFailed
{
    BOOL status = [self assertFail:@{@"testProp" : @(1)}];
    XCTAssert(status);
}

- (void)testStringMaxLengthFailed
{

    BOOL status = [self assertFail:@{@"testProp" : @"012345678910"}];
    XCTAssert(status);
}

- (void)testStringMinLengthFailed
{
    BOOL status = [self assertFail:@{@"testProp" : @"01"}];
    XCTAssert(status);
}

- (void)testStringPattern
{
    BOOL status = [self assertOk:@{@"testRegExp" : @"01abcd"}];
    XCTAssert(status);
}

- (void)testStringPatternFail
{
    BOOL status = [self assertFail:@{@"testRegExp" : @"012acd"}];
    XCTAssert(status);
}
@end