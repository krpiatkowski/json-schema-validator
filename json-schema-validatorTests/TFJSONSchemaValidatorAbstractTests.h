//
//  TFJSONSchemaValidatorAbstractTests.h
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 06/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import <XCTest/XCTest.h>
@interface TFJSONSchemaValidatorAbstractTests : XCTestCase
- (NSString *)schema;
- (BOOL)assertOk:(NSDictionary *)json;
- (BOOL)assertFail:(NSDictionary *)json;
@end