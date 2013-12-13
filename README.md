json-schema-validator
=====================

A json schema validator for iOS based on http://json-schema.org

Installing
----------
The classes can be added to your project by including [/json-schema-validator/Classes/\*](https://github.com/krpiatkowski/json-schema-validator/tree/master/json-schema-validator/Classes) and [/json-schema-validator/Resources/\*](https://github.com/krpiatkowski/json-schema-validator/tree/master/json-schema-validator/Resources)

or even easier just install it as a [CocoaPod](cocoapods.org).

Usage
-----

	NSError *errors = [[TFJSONSchemaValidator validator] validate:json withSchemaPath:@"someSchema"]

The parameter json is a NSDictionary representation of the json string, created by using NSJSONSerializer.

If reading up or parsing the schema fails *errors* will be a NSJSONSerializer error.
Otherwise *errors.userInfo[@"errors"]* is a array with all the validations errors

Any schema provided is validated against the [Core/Validation schema](http://json-schema.org/schema)




Deviations from specification
=============================

instance type validation
------------------------
Of a object has more then on of the following:
type, enum, $ref, allOf, anyOf, not

The validation fails with a prefixed with "schema-error"

The reason for this is that the specification does not mention what happens if more then one of the keywords is found.

What does the following mean?

 	{ 
	 	"allOf" : [{"type" : "string"}],
	 	"anyOf" : [{"type" : "number"}, {"type" : "null"}]
 	}


Regular expressions
-------------------
Regular expression engine and syntax is not [ecma262](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf), instead [ICU](http://userguide.icu-project.org/strings/regexp) is used.

The reason for this is that ICU is the engine build into Objective-C and makes parsing and running expressions alot simpler.

Bundle
------
$ref's can reference to a schema in the same NSBundle specified in the constructor (default is [NSBundle mainBundle]).
Schemas are refereced like this: bundle://filename.json



Missing from implementation
===========================
Numeric
----------
* multipleOf
* exclusiveMaximum
* exclusiveMinimum

String
------
* format

array
-----
* uniqueItems

objects
-------
* maxProperties
* minProperties
* additionalProperties
* dependencies

instance type
-------------
* not
* definitions (only external and any definitions below root level are missing)

