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

@interface TFJSONSchemaValidatorNumbericTests : TFJSONSchemaValidatorAbstractTests

@end

@implementation TFJSONSchemaValidatorNumbericTests
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

- (void)testIntegerFail
{
    BOOL status = [self assertFail:@{@"testInteger" : @(1.1)}];
    XCTAssert(status);
}

- (void)testBoolean
{
    NSString *jsonString = @"{\"testBoolean\":true}";
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    BOOL status = [self assertOk:json];
    XCTAssert(status);
}

- (void)testBooleanFail
{
    NSString *jsonString = @"{\"testBoolean\":1.2}";
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    BOOL status = [self assertFail:json];
    XCTAssert(status);
}

- (void)testBooleanFail2
{
    NSString *jsonString = @"{\"testBoolean\":1}";
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    BOOL status = [self assertFail:json];
    XCTAssert(status);
}
@end