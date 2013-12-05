//
//  TFJSONSchemaValidatorObjectTests.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 04/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TFJSONSchemaValidatorAbstractTests.h"
#import "TFJSONSchemaValidator.h"

@interface TFJSONSchemaValidatorObjectTests : TFJSONSchemaValidatorAbstractTests
@end

@implementation TFJSONSchemaValidatorObjectTests

- (NSString *)schemaName
{
    return @"TFJSONSchemaValidatorObjectTests";
}

- (void)testNestedObjects
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"level1" : @{@"level2" : @{@"level3" : @{}}}} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"Nesting should be supported");
}

- (void)testNotMissing
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"missing" : @{@"prop1" : @"prop1", @"prop2" : @"prop2", @"prop3" : @"prop3"}} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"Should not miss anything");
}

- (void)testMissingAll
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"missing" : @{}} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"Should miss all");
}

- (void)testMissingSome
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"missing" : @{@"prop1" : @"prop1"}} withSchema:self.schema];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"Should miss some");
}
@end