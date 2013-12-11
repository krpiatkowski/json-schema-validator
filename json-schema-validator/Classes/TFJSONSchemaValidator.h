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
- (id)initWithBundle:(NSBundle *)bundle;
- (NSError *)validate:(NSDictionary *)jsonObject withSchemaPath:(NSString *)path;
- (NSString *)prettyPrintErrors:(NSError *)errors;
@end