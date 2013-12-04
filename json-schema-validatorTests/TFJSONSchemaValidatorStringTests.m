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

- (NSString *)schemaName
{
    return @"TFJSONSchemaValidatorStringTests";
}

- (void)testStringValidation
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testProp" : @"test"} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"input is valid according to schema");
}

- (void)testStringValidationFailed
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testProp" : @(1)} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"input is invalid according to schema");
}

- (void)testStringMaxLengthFailed
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testProp" : @"012345678910"} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"String should be to long");
}

- (void)testStringMinLengthFailed
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testProp" : @"01"} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"String should be to short");
}
@end