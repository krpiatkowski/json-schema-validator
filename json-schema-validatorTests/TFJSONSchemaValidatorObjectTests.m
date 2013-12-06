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
- (NSString *)schema
{
    return @"TFJSONSchemaValidatorObjectTests";
}
- (void)testNestedObjects
{
    BOOL status = [self assertOk:@{@"level1" : @{@"level2" : @{@"level3" : @{}}}}];
    XCTAssert(status);
}

- (void)testNotMissing
{
    BOOL status = [self assertOk:@{@"missing" : @{@"prop1" : @"prop1", @"prop2" : @"prop2", @"prop3" : @"prop3"}}];
    XCTAssert(status);
}

- (void)testMissingAll
{
    BOOL status = [self assertFail:@{@"missing" : @{}}];
    XCTAssert(status);
}

- (void)testMissingSome
{
    BOOL status = [self assertFail:@{@"missing" : @{@"prop1" : @"prop1"}}];
    XCTAssert(status);
}
@end