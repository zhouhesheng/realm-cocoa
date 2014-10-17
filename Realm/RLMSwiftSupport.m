////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import "RLMSwiftSupport.h"

#import "RLMObject.h"
#import "RLMProperty.h"

#import <objc/runtime.h>

@implementation RLMSwiftSupport

// NSStringFromClass demangles names for top-level classes, but not for nested
// classes. The format for Swift class names is:
// _TtCC9iOS_Tests17SwiftNestedObject10ChildClass
// _T indicates it is a Swift symbol, t indicates that the symbol is a type, C
// is repeated once for each class in the name, 9 is the length of the module
// name, iOS_Tests is the module name, and then there is a repeated sequence of class
// name length followed by the class name for each class in the nesting
+ (BOOL)isSwiftClassName:(NSString *)className {
    // because top-level classes are demangled, there will always be at least
    // two Cs
    return [className containsString:@"."] || [className hasPrefix:@"_TtCC"];
}

+ (NSString *)demangleClassName:(NSString *)className {
    NSUInteger dot = [className rangeOfString:@"."].location;
    if (dot != NSNotFound) {
        // drop module name from pre-demangled name
        return [className substringFromIndex:dot + 1];
    }

    const char *str = className.UTF8String + 3; // skip _Tt
    while (*str == 'C') { // skip Cs
        ++str;
    }

    // Skip module name
    long len = strtol(str, (char **)&str, 10);
    str += len;

    // Read the class names
    // Doesn't convert punycode for Unicode class names
    NSMutableString *demanged = [NSMutableString stringWithCapacity:strlen(str)];
    while (*str) {
        if (demanged.length) {
            [demanged appendString:@"."];
        }

        long len = strtol(str, (char **)&str, 10);
        [demanged appendString:[[NSString alloc] initWithBytesNoCopy:(void *)str length:len encoding:NSUTF8StringEncoding freeWhenDone:NO]];
        str += len;
    }

    return demanged;
}
@end
