//
//  NSDictionary+JSONPointer.h
//  JSON Pointer Category for NSDictionary.
//
//  Created by Jonathan on 31/01/2014.
//  Copyright (c) 2014 Jonathan Dring. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(CWJSONPointer)

- (id)objectForPointer:(NSString*)pointer;

- (NSArray*)NSArrayForPointer:(NSString*)pointer;
- (NSNumber*)NSNumberForPointer:(NSString*)pointer;
- (NSNumber*)BooleanForPointer:(NSString*)pointer;
- (NSString*)NSStringForPointer:(NSString*)pointer;
- (NSDictionary*)NSDictionaryForPointer:(NSString*)pointer;

@end
