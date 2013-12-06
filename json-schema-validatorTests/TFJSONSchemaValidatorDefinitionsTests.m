//
//  TFJSONSchemaValidatorDefinitionsTests.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 06/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TFJSONSchemaValidator.h"

@interface TFJSONSchemaValidatorDefinitionsTests : XCTestCase

@end

static NSString *kSchemaName = @"TFJSONSchemaValidatorDefinitionsTests";

@implementation TFJSONSchemaValidatorDefinitionsTests

- (void)testLoadedDefinitions
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testDefinitions" : @"#AABBCC"} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNil(error, @"string should be a color and validated");
}

- (void)testLoadedDefinitionsFailed
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:@{@"testDefinitions" : @"AABBCC"} withSchemaPath:kSchemaName bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    XCTAssertNotNil(error, @"string should be a color and validated");
}

@end
