//
//  TFJSONSchemaValidatorUseCaseTests.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 10/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TFJSONSchemaValidatorAbstractTests.h"

@interface TFJSONSchemaValidatorUseCaseTests : TFJSONSchemaValidatorAbstractTests
@end

@implementation TFJSONSchemaValidatorUseCaseTests

- (void)testDefinitionsWithTypesFail
{
    BOOL status = [self assertFailWithSchema:@"testDefinitionsWithTypesFailSchema" data:@"testDefinitionsWithTypesFailData"];
    XCTAssert(status);
}

@end
