//
//  TFJSONSchemaValidatorAbstractTests.h
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 04/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//
@interface TFJSONSchemaValidatorAbstractTests : XCTestCase
@property (nonatomic, strong) NSDictionary *schema;
- (NSString *)schemaName;
@end