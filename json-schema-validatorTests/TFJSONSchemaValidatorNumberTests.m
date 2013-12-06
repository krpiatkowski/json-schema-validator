//
//  TFJSONSchemaValidatorNumberTests.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 04/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TFJSONSchemaValidator.h"

@interface TFJSONSchemaValidatorNumberTests : XCTestCase

@end
static NSString *kSchemaName = @"TFJSONSchemaValidatorNumberTests";

@implementation TFJSONSchemaValidatorNumberTests

- (void)testNumberValidation
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testProp" : @(200)} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"200 is a valid number");
}

- (void)testNumberMaximumFailed
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testProp" : @(9999)} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"9999 should be larger then 999");
}

- (void)testNumberMinimumFailed
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testProp" : @(0)} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"0 is smaller then 100");
}

- (void)testNumberMaximumFloatFailed
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testProp" : @(9999.9)} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"9999.9 is larger then 999");
}

- (void)testNumberMinimumFloatFailed
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testProp" : @(9.9)} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"9.9 is smaller then 100");
}

- (void)testNumberNegative
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testPropNegative" : @(-199)} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"-199 is smaller then -100 and larger then -999");
}
@end