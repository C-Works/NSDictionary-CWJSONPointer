NSDictionary+CWJSONPointer
==========================

A native Objective-C JSON Pointer Category.

Development discussion [here] [devLink]

[devlink]: https://groups.google.com/forum/#!forum/cwjsonpointer



To use this category, include it in your code with:

``` objective-c
#import "NSDictionary+CWJSONPointer.h"
```

You can then use an RFC6901 JSON Pointer to fetch objects:
``` Objective-C
NSDictionary *json = [NSJSONSerialization JSONObjectWithData: data options:0 error: &error ];
[json objectForPointer: @"/foo/bar"   ]
```

Or you can do the same using a JSON URI Fragment:
```Objective-C
NSDictionary *json = [NSJSONSerialization JSONObjectWithData: data options:0 error: &error ];
[json objectForPointer: @"#/foo/bar" ]
```

If you want to validate the returned object type use of the following methods:
```Objective-C
NSDictionary *json = [NSJSONSerialization JSONObjectWithData: data options:0 error: &error ];
[json NSArrayForPointer:      @"/foo/bar" ]
[json BooleanForPointer:      @"/foo/bar" ]
[json NSStringForPointer:     @"/foo/bar" ]
[json NSNumberForPointer:     @"/foo/bar" ]
[json NSDictionaryForPointer: @"/foo/bar" ]
```

If you want to validate the returned object type for fragments use the same methods:
```Objective-C
NSDictionary *json = [NSJSONSerialization JSONObjectWithData: data options:0 error: &error ];
[json NSArrayForPointer:      @"#/foo/bar" ]
[json BooleanForPointer:      @"#/foo/bar" ]
[json NSStringForPointer:     @"#/foo/bar" ]
[json NSNumberForPointer:     @"#/foo/bar" ]
[json NSDictionaryForPointer: @"#/foo/bar" ]
```
Note: Boolean returns an NSNumber with three possible states: null, 0 or 1. If the json contains the number 1 or 0 it will return valid, but will return false for all numbers above 1 or below 0.
