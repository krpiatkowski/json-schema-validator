//
//  TFJSONSchemaValidatorSetsTests.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 11/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TFJSONSchemaValidatorAbstractTests.h"

@interface TFJSONSchemaValidatorSetsTests : TFJSONSchemaValidatorAbstractTests

@end

@implementation TFJSONSchemaValidatorSetsTests

- (NSString *)schema
{
    return @"TFJSONSchemaValidatorSetsTests";
}

- (void)testAllOf
{
    BOOL status = [self assertOk:@{@"testAllOf" : @(5)}];
    XCTAssert(status);
}

- (void)testAllOfFail
{
    BOOL status = [self assertFail:@{@"testAllOf" : @(2)}];
    XCTAssert(status);
}

- (void)testAnyOf
{
    BOOL status = [self assertOk:@{@"testAnyOf" : @(1)}];
    XCTAssert(status);
}

- (void)testAnyOfFail
{
    BOOL status = [self assertFail:@{@"testAnyOf" : @(0)}];
    XCTAssert(status);
}

- (void)testOneOf
{
    BOOL status = [self assertOk:@{@"testOneOf" : @(2)}];
    XCTAssert(status);
}

- (void)testOneOfFail
{
    BOOL status = [self assertFail:@{@"testOneOf" : @(5)}];
    XCTAssert(status);
}
@end
