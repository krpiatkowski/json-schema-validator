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

@interface TFJSONSchemaValidatorStringTests : XCTestCase

@end


static NSString *kSchemaName = @"TFJSONSchemaValidatorStringTests";
@implementation TFJSONSchemaValidatorStringTests

- (void)testStringValidation
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testProp" : @"test"} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"input is valid according to schema");
}

- (void)testStringValidationFailed
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testProp" : @(1)} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"input is invalid according to schema");
}

- (void)testStringMaxLengthFailed
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testProp" : @"012345678910"} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"String should be to long");
}

- (void)testStringMinLengthFailed
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testProp" : @"01"} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"String should be to short");
}

- (void)testStringPattern
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testRegExp" : @"01abcd"} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"Follows pattern");
}

- (void)testStringPatternFail
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testRegExp" : @"012acd"} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"Does not follows pattern");
}
@end