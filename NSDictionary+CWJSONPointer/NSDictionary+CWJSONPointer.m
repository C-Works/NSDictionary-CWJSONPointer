//
//  NSDictionary+CWJSONPointer.m
//  JSON Pointer Category for NSDictionary.
//
//  Created by Jonathan on 31/01/2014.
//  Copyright (c) 2014 Jonathan Dring. All rights reserved.
//

#import "NSDictionary+CWJSONPointer.h"

// JSON Pointer RFC 6901 April 2013
@implementation NSDictionary(CWJSONPointer)

- (id)objectForPointer:(NSString*)pointer
{
    if( !pointer )                      {
        // Undocumented behavior, terminate evaluation.
        return nil;
    }
 
    // Section 6: URI fragment evaluation: if a fragment, remove the fragment marker and de-escape.
    if( [pointer hasPrefix:@"#"]       ){
        pointer = [pointer substringFromIndex:1];
        pointer = [pointer stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    if( [pointer isEqualToString:@""    ] ){
        // Section 5. Blank Pointer evaluates to complete JSON document.
        return self;
    }
    else if( [pointer hasPrefix:@"/"    ] ){
        // Section 3. Legal leading '/', strip and continue;
        pointer = [pointer substringFromIndex:1];
    }
    else{
        //Section 3. Token without leading '/' is illegal, terminate evaluation
        return  nil;
    }
    
    //Section 3. Check for valid character ranges upper and lower limits.
    NSCharacterSet *illegalSet = [[NSCharacterSet characterSetWithRange:NSMakeRange(0x0000,0x10FFFF)] invertedSet];
    if ( [pointer rangeOfCharacterFromSet:illegalSet].location != NSNotFound ) {
        return nil;
    }

    // Section 4. Evaluate the tokens one by one starting with the root.
    id object = self;
    NSString *token = nil;
    NSArray *pointerArray = [pointer componentsSeparatedByString:@"/"];
    
    for ( token in pointerArray )
    {
        //Section 4. Transform the escaped characters, in the order ~1 then ~0.
        token = [token stringByReplacingOccurrencesOfString:@"~1" withString:@"/"];
        token = [token stringByReplacingOccurrencesOfString:@"~0" withString:@"~"];
        
        if( object == nil || object == [NSNull null] )
        {
            // If the object is nil or null, terminate evaluation.
            return nil;
        }
        else if([object isKindOfClass:[NSDictionary class]])
        {
            // Section 4. If value is an object return the referenced property.
            object = object[ token ];
        }
        else if ([object isKindOfClass:[NSArray class]])
        {
            // Section 4. Process array objects with ABNF Rule: 0x30/(0x31-39 *(0x30-0x39))
            NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
            if( ![[token stringByTrimmingCharactersInSet:numberSet] isEqualToString:@""] ){
                return nil;
            }
            // Section $. Check for leading zero's
            if( [token hasPrefix:@"0"] && [token length] > 1 ){
                return nil;
            }
            if( [token isEqualToString:@"-"] ){
                // Section 4. Non-existant array element, terminate evaluation.
                return nil;
            }
            // Section 4. Valid array reference so navigate to object.
            object = object[ [token integerValue] ];
        }
        else
        {
            // Unspecified object type, terminate evaluation.
            return  nil;
        }
    }
    return object;
}

- (NSString*)NSStringForPointer:(NSString *)pointer
{
    id object = [self objectForPointer:pointer];
    if( object && [object isKindOfClass:[NSString class] ] ){
        return object;
    }
    return nil;
}

- (NSNumber*)NSNumberForPointer:(NSString *)pointer
{
    id object = [self objectForPointer:pointer];
    if( object && [object isKindOfClass:[NSNumber class] ] ){
        return object;
    }
    return nil;
}

- (NSDictionary*)NSDictionaryForPointer:(NSString *)pointer
{
    id object = [self objectForPointer:pointer];
    if( object && [object isKindOfClass:[NSDictionary class] ] ){
        return object;
    }
    return nil;
}

- (NSArray*)NSArrayForPointer:(NSString *)pointer
{
    id object = [self objectForPointer:pointer];
    if( object && [object isKindOfClass:[NSArray class] ] ){
        return object;
    }
    return nil;
}

- (NSNumber*)BooleanForPointer:(NSString*)pointer
{
    id object = [self objectForPointer:pointer];
    if( object && [object isKindOfClass:[NSNumber class] ] ){
        if( [object intValue] > 1 || [object intValue] < 0 ){return nil;}
        return object;
    }
    return nil;
}

@end
