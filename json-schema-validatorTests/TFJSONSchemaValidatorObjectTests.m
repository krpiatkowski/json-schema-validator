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

@interface TFJSONSchemaValidatorObjectTests : XCTestCase
@end

static NSString *kSchemaName = @"TFJSONSchemaValidatorObjectTests";

@implementation TFJSONSchemaValidatorObjectTests

- (void)testNestedObjects
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"level1" : @{@"level2" : @{@"level3" : @{}}}} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"Nesting should be supported");
}

- (void)testNotMissing
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"missing" : @{@"prop1" : @"prop1", @"prop2" : @"prop2", @"prop3" : @"prop3"}} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"Should not miss anything");
}

- (void)testMissingAll
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"missing" : @{}} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"Should miss all");
}

- (void)testMissingSome
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"missing" : @{@"prop1" : @"prop1"}} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"Should miss some");
}
@end