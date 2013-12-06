//
//  TFJSONSchemaValidatorDefinitionsTests.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 06/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "TFJSONSchemaValidatorAbstractTests.h"
#import "TFJSONSchemaValidator.h"

@interface TFJSONSchemaValidatorDefinitionsTests : TFJSONSchemaValidatorAbstractTests

@end

@implementation TFJSONSchemaValidatorDefinitionsTests
- (NSString *)schema
{
    return @"TFJSONSchemaValidatorDefinitionsTests";
}

- (void)testLoadedDefinitions
{
    BOOL status = [self assertOk:@{@"testDefinitions" : @"#AABBCC"}];
    XCTAssert(status);
}

- (void)testLoadedDefinitionsFailed
{
    BOOL status = [self assertFail:@{@"testDefinitions" : @"AABBCC"}];
    XCTAssert(status);
}
@end
