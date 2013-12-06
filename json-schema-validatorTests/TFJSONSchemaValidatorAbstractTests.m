//
//  TFJSONSchemaValidatorAbstractTests.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 06/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import "TFJSONSchemaValidatorAbstractTests.h"
#import "TFJSONSchemaValidator.h"

@implementation TFJSONSchemaValidatorAbstractTests
- (NSString *)schema
{
    NSAssert(NO, @"Override in subclass");
    return @"";
}

- (BOOL)assertOk:(NSDictionary *)json
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:json withSchemaPath:[self schema] bundle:[NSBundle bundleForClass:[self class]]];
    NSLog(@"%@", [[TFJSONSchemaValidator validator] prettyPrintErrors:error]);
    return !error;
}

- (BOOL)assertFail:(NSDictionary *)json
{
    NSError *error = [[TFJSONSchemaValidator validator] validate:json withSchemaPath:[self schema] bundle:[NSBundle bundleForClass:[self class]]];
    if(error != nil){
        NSLog(@"Validation ok, should fail");
    }
    return error != nil;
}
@end
