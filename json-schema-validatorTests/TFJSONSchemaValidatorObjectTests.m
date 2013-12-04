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
    XCTAssertNil(error, @"input is valid according to schema");
}
@end