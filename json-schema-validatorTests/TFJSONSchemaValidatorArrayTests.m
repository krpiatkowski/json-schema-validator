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
- (NSString *)schemaName
{
    return @"TFJSONSchemaValidatorArrayTests";
}

- (void)testArray
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testSame" : @[]} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"A simple array without any elements is still of the type string");
}

- (void)testArraySame
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testSame" : @[@"test1", @"test2"]} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"The array only contain strings");
}

- (void)testArraySameMixedFail
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testSame" : @[@"test1", @(1)]} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"Mixing arrays is not allowed for testSame");
}

- (void)testArrayMixed
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testMixed" : @[@"test1", @(1)]} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"Mixing arrays should be allowed");
}

- (void)testArrayMixedFail
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testMixed" : @[@"test1", @"test2"]} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"Second parameter is not a number");
}

- (void)testArrayMixedNoAdditional
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testMixed" : @[@"test1", @(1)]} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"There is no additional items");
}

- (void)testArrayMixedNoAdditionalFail
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testMixedNoAdditional" : @[@"test1", @(1), @(1)]} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"There is a additional items");
}

- (void)testNestedArrays
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testNestedArrays" : @[@[@"test"]]} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"Nested arrays should be supported");
}
@end
