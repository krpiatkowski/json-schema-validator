//
//  TFJSONSchemaValidatorAbstractTests.m
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 04/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TFJSONSchemaValidatorAbstractTests.h"

@implementation TFJSONSchemaValidatorAbstractTests

- (void)setUp
{
    [super setUp];
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:[self schemaName] ofType:@"json"];
    
    NSError *error;
    _schema = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options: NSJSONReadingMutableContainers error: &error];
    if(error){
        NSLog(@"%@", error.userInfo);
    }
}

- (void)tearDown
{
    [super tearDown];
}

- (NSString *)schemaName
{
    NSAssert(NO, @"Implement in subclasses");
    return nil;
}
@end