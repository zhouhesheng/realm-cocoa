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

#import "RLMTestCase.h"
#import  <tightdb/data_type.hpp>
#import  <tightdb/group.hpp>
#import "RLMUtil.hpp"
#include <sys/mman.h>

@interface PropertyTypeTests : RLMTestCase
@end

@implementation PropertyTypeTests

- (void)testStuff {
    int fd = open(RLMRealm.defaultRealmPath.UTF8String, O_CREAT);
    size_t lo = 4096, hi = 1 << 31;
    while (hi - lo > 4096) {
        size_t size = (hi + lo) / 2;
        void *b = mmap(0, size, PROT_READ, MAP_SHARED, fd, 0);
        munmap(b, size);

        if (b == MAP_FAILED)
            hi = size;
        else
            lo = size;
    }
    NSLog(@"%zu %zu", lo, hi);

    tightdb::Group group(RLMRealm.defaultRealmPath.UTF8String, tightdb::Group::mode_ReadWrite);
    tightdb::TableRef table = group.add_table("table");
    table->add_column(tightdb::type_Binary, "data");

    char data[5000] = {0};

    NSLog(@"");
    for (int i = 0; i < 100000; ++i) {
        if (i % 1000 == 0)
            NSLog(@"%d", i);
        table->add_empty_row();
        table->set_binary(0, i, tightdb::BinaryData(data, sizeof data));
        if (i % 1000 == 0)
            group.commit();
    }

    NSLog(@"");
}

- (void)testPropertyTypes
{
    // Primitive types
    XCTAssertEqual((int)RLMPropertyTypeInt,     (int)tightdb::type_Int,         @"Int");
    XCTAssertEqual((int)RLMPropertyTypeBool,    (int)tightdb::type_Bool,        @"Bool");
    XCTAssertEqual((int)RLMPropertyTypeFloat,   (int)tightdb::type_Float,       @"Float");
    XCTAssertEqual((int)RLMPropertyTypeDouble,  (int)tightdb::type_Double,      @"Double");
    
    // Object types
    XCTAssertEqual((int)RLMPropertyTypeString,  (int)tightdb::type_String,      @"String");
    XCTAssertEqual((int)RLMPropertyTypeData,    (int)tightdb::type_Binary,      @"Binary");
    XCTAssertEqual((int)RLMPropertyTypeAny,     (int)tightdb::type_Mixed,       @"Mixed");
    XCTAssertEqual((int)RLMPropertyTypeDate,    (int)tightdb::type_DateTime,    @"Date");
    
    // Array/Linked object types
    XCTAssertEqual((int)RLMPropertyTypeObject,  (int)tightdb::type_Link,        @"Link");
    XCTAssertEqual((int)RLMPropertyTypeArray,   (int)tightdb::type_LinkList,    @"Link list");
    
    XCTAssertEqualObjects(RLMTypeToString(RLMPropertyTypeString),   @"string",  @"stringType");
    XCTAssertEqualObjects(RLMTypeToString(RLMPropertyTypeInt),      @"int",     @"intType");
    XCTAssertEqualObjects(RLMTypeToString(RLMPropertyTypeBool),     @"bool",    @"boolType");
    XCTAssertEqualObjects(RLMTypeToString(RLMPropertyTypeDate),     @"date",    @"dateType");
    XCTAssertEqualObjects(RLMTypeToString(RLMPropertyTypeData),     @"data",    @"dataType");
    XCTAssertEqualObjects(RLMTypeToString(RLMPropertyTypeDouble),   @"double",  @"doubleType");
    XCTAssertEqualObjects(RLMTypeToString(RLMPropertyTypeFloat),    @"float",   @"floatType");
    XCTAssertEqualObjects(RLMTypeToString(RLMPropertyTypeAny),      @"any",     @"anyType");
    XCTAssertEqualObjects(RLMTypeToString(RLMPropertyTypeObject),   @"object",  @"objectType");
    XCTAssertEqualObjects(RLMTypeToString(RLMPropertyTypeArray),    @"array",   @"arrayType");

    XCTAssertEqualObjects(RLMTypeToString(RLMPropertyType(-1)),    @"Unknown",   @"Unknown type");
}

@end
