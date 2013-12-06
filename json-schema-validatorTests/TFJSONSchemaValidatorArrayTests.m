//
//  TFJSONSchemaValidatorArrayTests.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 05/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TFJSONSchemaValidatorAbstractTests.h"
#import "TFJSONSchemaValidator.h"

@interface TFJSONSchemaValidatorArrayTests : TFJSONSchemaValidatorAbstractTests

@end

@implementation TFJSONSchemaValidatorArrayTests
- (NSString *)schema
{
    return @"TFJSONSchemaValidatorArrayTests";
}

- (void)testArray
{
    BOOL status = [self assertOk:@{@"testSame" : @[]}];
    XCTAssert(status);
}

- (void)testArraySame
{
    BOOL status = [self assertOk:@{@"testSame" : @[@"test1", @"test2"]}];
    XCTAssert(status);
}

- (void)testArraySameMixedFail
{
    BOOL status = [self assertFail:@{@"testSame" : @[@"test1", @(1)]}];
    XCTAssert(status);
}

- (void)testArrayMixed
{
    BOOL status = [self assertOk:@{@"testMixed" : @[@"test1", @(1)]}];
    XCTAssert(status);
}

- (void)testArrayMixedFail
{
    BOOL status = [self assertFail:@{@"testMixed" : @[@"test1", @"test2"]}];
    XCTAssert(status);
}

- (void)testArrayMixedNoAdditional
{
    BOOL status = [self assertOk:@{@"testMixed" : @[@"test1", @(1)]}];
    XCTAssert(status);
}

- (void)testArrayMixedNoAdditionalFail
{
    BOOL status = [self assertFail:@{@"testMixedNoAdditional" : @[@"test1", @(1), @(1)]}];
    XCTAssert(status);
}

- (void)testArrayMixedNoAdditionalFewerItems
{
    BOOL status = [self assertOk:@{@"testMixedNoAdditional" : @[@"test1"]}];
    XCTAssert(status);
}

- (void)testNestedArrays
{
    BOOL status = [self assertOk:@{@"testNestedArrays" : @[@[@"test"]]}];
    XCTAssert(status);
}
@end