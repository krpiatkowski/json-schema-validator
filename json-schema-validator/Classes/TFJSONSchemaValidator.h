//
//  TFJSONSchemaValidator.h
//  json-schema-validator
//
//  Created by Krzysztof Piatkowski on 04/12/13.
//  Copyright (c) 2013 Trifork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFJSONSchemaValidator : NSObject
+ (TFJSONSchemaValidator *)validator;
- (NSError *)validate:(NSDictionary *)jsonObject withSchemaPath:(NSString *)path;
- (NSError *)validate:(NSDictionary *)jsonObject withSchemaPath:(NSString *)path bundle:(NSBundle *)bundle;
- (NSError *)validate:(NSDictionary *)jsonObject withSchema:(NSDictionary *)schema;

- (NSString *)prettyPrintErrors:(NSError *)errors;
@end