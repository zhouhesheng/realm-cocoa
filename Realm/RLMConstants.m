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

#include <stdio.h>
#import <Foundation/Foundation.h>

#import <Realm/Realm.h>

NSString *const RLMRealmDidChangeNotification = @"RLMRealmDidChangeNotification";

@class RLMObjectSchema;

id RLMCreateAccessorRecorder(Class cls, __unused RLMObjectSchema *schema, NSString **lastPropertyAccessed) {
    NSString *name = [[cls className] stringByAppendingString:@"_rlmQueryThing"];
    Class impl = objc_lookUpClass(name.UTF8String);
    if (!impl) {
        impl = objc_allocateClassPair(cls, name.UTF8String, 0);

        // loop over object schema and make accessors of the correct type
        IMP imp = imp_implementationWithBlock(^{
            *lastPropertyAccessed = @"name";
            return nil;
        });
        class_replaceMethod(impl, NSSelectorFromString(@"name"), imp, "@:");

        objc_registerClassPair(impl);
    }

    return [[impl alloc] init];
}
