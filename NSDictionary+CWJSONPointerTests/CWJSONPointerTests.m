//
//  jsonPointerCategoryTests.m
//  Tests for NSDictionary_CWJSONPointer
//
//  Created by Jonathan on 31/01/2014.
//  Copyright (c) 2014 Jonathan Dring. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSDictionary+CWJSONPointer.h"

@interface jsonPointerTests : XCTestCase

@end

@implementation jsonPointerTests
{
    NSDictionary *_rjson;
    NSDictionary *_njson;
}

- (void)setUp
{
    NSError *error;
    [super setUp];
    
    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"RFC6901Specification" ofType:@"json"];
    XCTAssertNotNil(jsonPath, @"Failed to create RFC test file path");
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath ];
    XCTAssertNotNil(jsonData, @"Failed to get RFC test data from file");
    
    _rjson = [NSJSONSerialization JSONObjectWithData: jsonData options:0 error: &error ];
    XCTAssertNotNil(_rjson, @"Failed to deserialise RFC json data.");

    NSString *testPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"NonRFC6901TestCases" ofType:@"json"];
    XCTAssertNotNil(testPath, @"Failed to create Non-RFC test file path");
    
    NSData *testData = [NSData dataWithContentsOfFile:testPath ];
    XCTAssertNotNil(testData, @"Failed to get Non-RFC data from file");
    
    _njson = [NSJSONSerialization JSONObjectWithData: testData options:0 error: &error ];
    XCTAssertNotNil(_njson, @"Failed to deserialise Non-RFC json data.");
}

/* RFC6901 String Representations
""         // the whole document
"/foo"       ["bar", "baz"]
"/foo/0"    "bar"
"/"          0
"/a~1b"      1
"/c%d"       2
"/e^f"       3
"/g|h"       4
"/i\\j"      5
"/k\"l"      6
"/ "         7
"/m~0n"      8
*/
- (void)testRFC6901StringRepresentations
{
    NSArray  *arrayResult  = @[@"bar",@"baz"];
    
    XCTAssertEqualObjects( [ _rjson objectForPointer: @""       ], _rjson,                     @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"/foo"   ], arrayResult,                @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"/foo/0" ], @"bar",                     @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"/"      ], [NSNumber numberWithInt:0], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"/a~1b"  ], [NSNumber numberWithInt:1], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"/c%d"   ], [NSNumber numberWithInt:2], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"/e^f"   ], [NSNumber numberWithInt:3], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"/g|h"   ], [NSNumber numberWithInt:4], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"/i\\j"  ], [NSNumber numberWithInt:5], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"/k\"l"  ], [NSNumber numberWithInt:6], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"/ "     ], [NSNumber numberWithInt:7], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"/m~0n"  ], [NSNumber numberWithInt:8], @"Specified Test Failed");
}

/* RFC6901 URI Fragment Representations
#            the whole document
#/foo        ["bar", "baz"]
#/foo/0      "bar"
#/           0
#/a~1b       1
#/c%25d      2
#/e%5Ef      3
#/g%7Ch      4
#/i%5Cj      5
#/k%22l      6
#/%20        7
#/m~0n       8
*/
- (void)testRFC6901URIRepresentations
{
    NSArray  *arrayResult  = @[@"bar",@"baz"];
    
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"#"       ], _rjson,                     @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"#/foo"   ], arrayResult,                @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"#/foo/0" ], @"bar",                     @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"#/"      ], [NSNumber numberWithInt:0], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"#/a~1b"  ], [NSNumber numberWithInt:1], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"#/c%25d" ], [NSNumber numberWithInt:2], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"#/e%5Ef" ], [NSNumber numberWithInt:3], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"#/g%7Ch" ], [NSNumber numberWithInt:4], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"#/i%5Cj" ], [NSNumber numberWithInt:5], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"#/k%22l" ], [NSNumber numberWithInt:6], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"#/%20"   ], [NSNumber numberWithInt:7], @"Specified Test Failed");
    XCTAssertEqualObjects( [ _rjson objectForPointer: @"#/m~0n"  ], [NSNumber numberWithInt:8], @"Specified Test Failed");
}

- (void)testNegativeCases
{
    // Test for leading zeros to be rejected for
    XCTAssertNil( [ _rjson objectForPointer:      @"/u110000"         ], @"Invalid Character Not Nil"                                       );
    XCTAssertNil( [ _rjson objectForPointer:      @"/c%25d"           ], @"Escaping in non fragment pointer, should return nil."            );
    XCTAssertNil( [ _rjson objectForPointer:      @"/foo/00"          ], @"Invalid Array reference with leading zero's, should return nil." );
    XCTAssertNil( [ _rjson objectForPointer:      @"/foo/a"           ], @"Invalid Array reference with numbers, should return nil."        );

    XCTAssertNil([_njson NSNumberForPointer:      @"/foo/bar/string"  ], @"fetching string with NSNumberForPointer should fail."            );
    XCTAssertNil([_njson NSNumberForPointer:      @"/foo/bar/array"   ], @"fetching array  with NSNumberForPointer should fail."            );
    XCTAssertNil([_njson NSNumberForPointer:      @"/foo/bar/object"  ], @"fetching object with NSNumberForPointer should fail."            );
    XCTAssertNil([_njson NSNumberForPointer:      @"/foo/bar/null"    ], @"fetching null  with  NSNumberForPointer should fail."            );

    XCTAssertNil([_njson NSArrayForPointer:       @"/foo/bar/string"  ], @"fetching string with NSArrayForPointer should fail."             );
    XCTAssertNil([_njson NSArrayForPointer:       @"/foo/bar/true"    ], @"fetching bool  with  NSArrayForPointer should fail."             );
    XCTAssertNil([_njson NSArrayForPointer:       @"/foo/bar/number"  ], @"fetching number with NSArrayForPointer should fail."             );
    XCTAssertNil([_njson NSArrayForPointer:       @"/foo/bar/object"  ], @"fetching object with NSArrayForPointer should fail."             );
    XCTAssertNil([_njson NSArrayForPointer:       @"/foo/bar/null"    ], @"fetching null  with  NSArrayForPointer should fail."             );
 
    XCTAssertNil([_njson NSStringForPointer:      @"/foo/bar/array"   ], @"fetching array with  NSStringForPointer should fail."            );
    XCTAssertNil([_njson NSStringForPointer:      @"/foo/bar/true"    ], @"fetching bool  with  NSStringForPointer should fail."            );
    XCTAssertNil([_njson NSStringForPointer:      @"/foo/bar/number"  ], @"fetching number with NSStringForPointer should fail."            );
    XCTAssertNil([_njson NSStringForPointer:      @"/foo/bar/object"  ], @"fetching object with NSStringForPointer should fail."            );
    XCTAssertNil([_njson NSStringForPointer:      @"/foo/bar/null"    ], @"fetching null  with  NSStringForPointer should fail."            );

    XCTAssertNil([_njson NSDictionaryForPointer:  @"/foo/bar/array"   ], @"fetching array with  NSDictionaryForPointer should fail."        );
    XCTAssertNil([_njson NSDictionaryForPointer:  @"/foo/bar/true"    ], @"fetching bool  with  NSDictionaryForPointer should fail."        );
    XCTAssertNil([_njson NSDictionaryForPointer:  @"/foo/bar/number"  ], @"fetching number with NSDictionaryForPointer should fail."        );
    XCTAssertNil([_njson NSDictionaryForPointer:  @"/foo/bar/string"  ], @"fetching string with NSDictionaryForPointer should fail."        );
    XCTAssertNil([_njson NSDictionaryForPointer:  @"/foo/bar/null"    ], @"fetching null  with  NSDictionaryForPointer should fail."        );

    XCTAssertNil([_njson BooleanForPointer:       @"/foo/bar/array"   ], @"fetching array with  BooleanForPointer should fail."             );
    XCTAssertNil([_njson BooleanForPointer:       @"/foo/bar/object"  ], @"fetching object with BooleanForPointer should fail."             );
    XCTAssertNil([_njson BooleanForPointer:       @"/foo/bar/string"  ], @"fetching string with BooleanForPointer should fail."             );
    XCTAssertNil([_njson BooleanForPointer:       @"/foo/bar/null"    ], @"fetching null  with  BooleanForPointer should fail."             );
    XCTAssertNil([_njson BooleanForPointer:       @"/foo/bar/number"  ], @"fetching null  with  BooleanForPointer should fail."             );
    XCTAssertNil([_njson BooleanForPointer:       @"/foo/bar/negative"], @"fetching null  with  BooleanForPointer should fail."             );
    
    XCTAssertTrue([[_njson NSArrayForPointer:     @"/foo/bar/array"   ] isKindOfClass:[NSArray class]],      @"Should be an array"          );
    XCTAssertTrue([[_njson NSStringForPointer:    @"/foo/bar/string"  ] isKindOfClass:[NSString class]],     @"Should be an array"          );
    XCTAssertTrue([[_njson NSNumberForPointer:    @"/foo/bar/number"  ] isKindOfClass:[NSNumber class]],     @"Should be an array"          );
    XCTAssertTrue([[_njson NSDictionaryForPointer:@"/foo/bar/object"  ] isKindOfClass:[NSDictionary class]], @"Should be an array"          );
    
    XCTAssertEqual([[_njson BooleanForPointer:    @"/foo/bar/true"    ] boolValue ], YES, @"fetching bool with bool should pass."           );
    XCTAssertEqual([[_njson BooleanForPointer:    @"/foo/bar/false"   ] boolValue ], NO,  @"fetching bool with bool should pass."           );
    XCTAssertEqual([[_njson NSNumberForPointer:   @"/foo/bar/number"  ] intValue  ], 55,  @"fetching number with number should pass."       );
    XCTAssertEqual([[_njson NSNumberForPointer:   @"/foo/bar/negative"] intValue  ], -55, @"fetching number with number should pass."       );

    NSArray *array = @[ @1, @2, @3 ];
    NSDictionary *dictionary = @{ @"a":@1, @"b":@2, @"c":@3 };
    XCTAssertEqualObjects([_njson NSStringForPointer:     @"/foo/bar/string" ], @"mystring", @"fetching string with string should pass."    );
    XCTAssertEqualObjects([_njson NSArrayForPointer:      @"/foo/bar/array"  ], array,       @"fetching array  with array  should fail."    );
    XCTAssertEqualObjects([_njson NSDictionaryForPointer: @"/foo/bar/object" ], dictionary,  @"fetching object with dictionary should fail.");
}

- (void)tearDown
{
    [super tearDown];
}

@end
