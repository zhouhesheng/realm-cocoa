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

extern "C" {
#import "RLMTestCase.h"
#import "RLMSchema_Private.h"
}
#import "RLMMigration.h"
#import "RLMObjectSchema_Private.hpp"
#import "RLMProperty_Private.h"
#import "RLMRealm_Dynamic.h"
#import "RLMRealm_Private.hpp"

@interface IntPKObject : RLMObject
@property(nonatomic) int pk;
@end

@implementation IntPKObject
+ (NSString *)primaryKey { return @"pk"; }
@end

@interface PKTest : RLMTestCase
@end

@implementation PKTest
//* thread #4: tid = 0x10532bd, 0x03a236cc iOS Tests`long long (anonymous namespace)::get_direct<16>(data=0x054f80f0, ndx=0) + 28 at array.cpp:2612, queue = 'queue', stop reason = EXC_BAD_ACCESS (code=1, address=0x54f80f0)
//* frame #0: 0x03a236cc iOS Tests`long long (anonymous namespace)::get_direct<16>(data=0x054f80f0, ndx=0) + 28 at array.cpp:2612
//frame #1: 0x03a22101 iOS Tests`(anonymous namespace)::get_direct(data=0x054f80f0, width=16, ndx=0) + 65 at array.cpp:2628
//frame #2: 0x03a391c2 iOS Tests`unsigned long tightdb::Array::index_string<(this=0x7b9770b0, value=<unavailable>, result=0xb0114840, result_ref=0xb0114854, column=0x7b991130, get_func=0x03b86570)0, tightdb::StringData>(tightdb::StringData, tightdb::Column&, unsigned long&, void*, tightdb::StringData (*)(void*, unsigned long, char*)) const + 210 at array.cpp:2999
//frame #3: 0x03a1f4d1 iOS Tests`tightdb::Array::IndexStringFindFirst(this=0x7b9770b0, value=(m_data = "", m_size = 8), column=0x7b991130, get_func=0x03b86570)(void*, unsigned long, char*)) const + 113 at array.cpp:3135
//frame #4: 0x03b8bece iOS Tests`unsigned long tightdb::StringIndex::find_first<long long>(this=0x7b99a920, value=0) const + 94 at index_string.hpp:68
//frame #5: 0x03b868c3 iOS Tests`tightdb::Column::find_first(this=0x7b991130, value=0, begin=0, end=4294967295) const + 339 at column.cpp:790
//frame #6: 0x03cbd477 iOS Tests`unsigned long tightdb::Table::find_first<long long>(this=0x7cc5d600, col_ndx=0, value=0) const + 327 at table.cpp:3096
//frame #7: 0x03cab3d8 iOS Tests`tightdb::Table::find_first_int(this=0x7cc5d600, col_ndx=0, value=0) const + 56 at table.cpp:3108
//frame #8: 0x03991f82 iOS Tests`unsigned int RLMCreateOrGetRowForObject<RLMCreateObjectInRealmWithValue::$_1>(schema=0x7b976e50, primaryValueGetter=<unavailable>, options=6, created=0xb0114d3f) + 562 at RLMObjectStore.mm:315
//frame #9: 0x03991173 iOS Tests`RLMCreateObjectInRealmWithValue(realm=0x7b9794d0, className=0x7ae621e0, value=0x7b94da80, options=6) + 691 at RLMObjectStore.mm:423
//frame #10: 0x03984ee8 iOS Tests`+[RLMObject createOrUpdateInRealm:withObject:](self=0x03e0a294, _cmd=0x7ae59630, realm=0x7b9794d0, value=0x7b94da80) + 168 at RLMObject.mm:67
//frame #11: 0x03793d27 iOS Tests`__19-[PKTest testStuff]_block_invoke(.block_descriptor=<unavailable>) + 295 at MigrationTests.mm:50
//frame #12: 0x01a47e5a libdispatch.dylib`_dispatch_call_block_and_release + 15
//frame #13: 0x01a64f0f libdispatch.dylib`_dispatch_client_callout + 14
//frame #14: 0x01a4d0e8 libdispatch.dylib`_dispatch_queue_drain + 411
//frame #15: 0x01a4cded libdispatch.dylib`_dispatch_queue_invoke + 197
//frame #16: 0x01a4f2c2 libdispatch.dylib`_dispatch_root_queue_drain + 428
//frame #17: 0x01a5045a libdispatch.dylib`_dispatch_worker_thread2 + 39
//frame #18: 0x01dcbdab libsystem_pthread.dylib`_pthread_wqthread + 336
//frame #19: 0x01dcfcce libsystem_pthread.dylib`start_wqthread + 30

- (void)testStuff {
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i < 3; ++i) {
        dispatch_async(queue, ^{
            for (int j = 0; j < 50; ++j) {
                RLMRealm *realm = RLMRealm.defaultRealm;
                [realm beginWriteTransaction];
                [IntPKObject createOrUpdateInRealm:realm withObject:@[@0]];
                [realm commitWriteTransaction];
            }
        });
        // wait for the async block
        dispatch_sync(queue, ^{});
    }
}
@end

@interface MigrationObject : RLMObject
@property int intCol;
@property NSString *stringCol;
@end

@implementation MigrationObject
@end

@interface MigrationPrimaryKeyObject : RLMObject
@property int intCol;
@end

@implementation MigrationPrimaryKeyObject
+ (NSString *)primaryKey {
    return @"intCol";
}
@end

@interface MigrationStringPrimaryKeyObject : RLMObject
@property NSString * stringCol;
@end

@implementation MigrationStringPrimaryKeyObject
+ (NSString *)primaryKey {
    return @"stringCol";
}
@end

@interface MigrationTests : RLMTestCase
@end

@implementation MigrationTests

- (RLMRealm *)realmWithSingleObject:(RLMObjectSchema *)objectSchema {
    // modify object schema to use RLMObject class (or else bad accessors will get created)
    objectSchema.objectClass = RLMObject.class;
    objectSchema.accessorClass = RLMObject.class;

    RLMSchema *schema = [[RLMSchema alloc] init];
    schema.objectSchema = @[objectSchema];
    RLMRealm *realm = [self realmWithTestPathAndSchema:schema];

    // Set the initial version to 0 since we're pretending this was created with
    // a shared schema
    [realm beginWriteTransaction];
    RLMRealmSetSchemaVersion(realm, 0);
    [realm commitWriteTransaction];

    return realm;
}

- (void)testSchemaVersion {
    [RLMRealm setDefaultRealmSchemaVersion:1 withMigrationBlock:^(__unused RLMMigration *migration,
                                                      __unused NSUInteger oldSchemaVersion) {
    }];

    RLMRealm *defaultRealm = [RLMRealm defaultRealm];
    XCTAssertEqual(1U, RLMRealmSchemaVersion(defaultRealm));
}

- (void)testGetSchemaVersion {
    XCTAssertThrows([RLMRealm schemaVersionAtPath:RLMRealm.defaultRealmPath encryptionKey:nil error:nil]);
    @autoreleasepool {
        [RLMRealm defaultRealm];
    }

    XCTAssertEqual(0U, [RLMRealm schemaVersionAtPath:RLMRealm.defaultRealmPath encryptionKey:nil error:nil]);
    [RLMRealm setDefaultRealmSchemaVersion:1 withMigrationBlock:^(__unused RLMMigration *migration,
                                                                  __unused NSUInteger oldSchemaVersion) {
    }];

    RLMRealm *realm = [RLMRealm defaultRealm];
    XCTAssertEqual(1U, [RLMRealm schemaVersionAtPath:RLMRealm.defaultRealmPath encryptionKey:nil error:nil]);
    realm = nil;
}

- (void)testPerRealmMigration {
    @autoreleasepool {
        [RLMRealm defaultRealm];
    }

    XCTAssertEqual(0U, [RLMRealm schemaVersionAtPath:RLMRealm.defaultRealmPath encryptionKey:nil error:nil]);
    [RLMRealm setDefaultRealmSchemaVersion:1 withMigrationBlock:nil];

    @autoreleasepool {
        RLMRealm *defaultRealm = [RLMRealm defaultRealm];
        RLMRealm *anotherRealm = [RLMRealm realmWithPath:RLMTestRealmPath()];

        XCTAssertEqual(1U, [RLMRealm schemaVersionAtPath:defaultRealm.path encryptionKey:nil error:nil]);
        XCTAssertEqual(0U, [RLMRealm schemaVersionAtPath:anotherRealm.path encryptionKey:nil error:nil]);
    }

    __block bool migrationComplete = false;
    [RLMRealm setSchemaVersion:2 forRealmAtPath:RLMTestRealmPath() withMigrationBlock:^(__unused RLMMigration *migration,
                                                                                        __unused NSUInteger oldSchemaVersion) {
        migrationComplete = true;
    }];
    RLMRealm *anotherRealm = [RLMRealm realmWithPath:RLMTestRealmPath()];

    XCTAssertEqual(2U, [RLMRealm schemaVersionAtPath:anotherRealm.path encryptionKey:nil error:nil]);
    XCTAssertTrue(migrationComplete);
}

- (void)testAddingProperty {
    // create schema to migrate from with single string column
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationObject.class];
    objectSchema.properties = @[objectSchema.properties[0]];

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationObject.className withObject:@[@1]];
    [realm createObject:MigrationObject.className withObject:@[@2]];
    [realm commitWriteTransaction];

    // open realm with new schema before migration to test migration is necessary
    objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationObject.class];
    XCTAssertThrows([self realmWithTestPath], @"Migration should be required");
    
    // apply migration
    [RLMRealm setSchemaVersion:1 forRealmAtPath:RLMTestRealmPath() withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
        XCTAssertEqual(oldSchemaVersion, 0U, @"Initial schema version should be 0");
        [migration enumerateObjects:MigrationObject.className
                              block:^(RLMObject *oldObject, RLMObject *newObject) {
            XCTAssertThrows(oldObject[@"stringCol"], @"stringCol should not exist on old object");
            NSNumber *intObj;
            XCTAssertNoThrow(intObj = oldObject[@"intCol"], @"Should be able to access intCol on oldObject");
            NSString *stringObj = [NSString stringWithFormat:@"%@", intObj];
            XCTAssertNoThrow(newObject[@"stringCol"] = stringObj, @"Should be able to set stringCol");
        }];
    }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];

    // verify migration
    realm = [self realmWithTestPath];
    MigrationObject *mig1 = [MigrationObject allObjectsInRealm:realm][1];
    XCTAssertEqual(mig1.intCol, 2, @"Int column should have value 2");
    XCTAssertEqualObjects(mig1.stringCol, @"2", @"String column should be populated");

    [RLMRealm setSchemaVersion:0 forRealmAtPath:RLMTestRealmPath() withMigrationBlock:nil];
    XCTAssertThrows([RLMRealm migrateRealmAtPath:RLMTestRealmPath()]);
}


- (void)testRemoveProperty {
    // create schema to migrate from with single string column
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationObject.class];
    RLMProperty *thirdProperty = [[RLMProperty alloc] initWithName:@"deletedCol" type:RLMPropertyTypeBool objectClassName:nil attributes:(RLMPropertyAttributes)0];
    thirdProperty.column = 2;
    objectSchema.properties = [objectSchema.properties arrayByAddingObject:thirdProperty];

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationObject.className withObject:@[@1, @"1", @YES]];
    [realm createObject:MigrationObject.className withObject:@[@2, @"2", @NO]];
    [realm commitWriteTransaction];

    // apply migration
    [RLMRealm setSchemaVersion:1 forRealmAtPath:RLMTestRealmPath() withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
        XCTAssertEqual(oldSchemaVersion, 0U, @"Initial schema version should be 0");
        [migration enumerateObjects:MigrationObject.className
                                       block:^(RLMObject *oldObject, RLMObject *newObject) {
            XCTAssertNoThrow(oldObject[@"deletedCol"], @"Deleted column should be accessible on old object.");
            XCTAssertThrows(newObject[@"deletedCol"], @"Deleted column should not be accessible on new object.");
        }];
    }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];

    // verify migration
    realm = [self realmWithTestPath];
    MigrationObject *mig1 = [MigrationObject allObjectsInRealm:realm][1];
    XCTAssertThrows(mig1[@"deletedCol"], @"Deleted column should no longer be accessible.");
}

- (void)testRemoveAndAddProperty {
    // create schema to migrate from with single string column
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationObject.class];
    RLMProperty *oldInt = [[RLMProperty alloc] initWithName:@"oldIntCol" type:RLMPropertyTypeInt objectClassName:nil attributes:(RLMPropertyAttributes)0];
    objectSchema.properties = @[oldInt, objectSchema.properties[1]];

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationObject.className withObject:@[@1, @"1"]];
    [realm createObject:MigrationObject.className withObject:@[@1, @"2"]];
    [realm commitWriteTransaction];

    // object migration object
    void (^migrateObjectBlock)(RLMObject *, RLMObject *) = ^(RLMObject *oldObject, RLMObject *newObject) {
        XCTAssertNoThrow(oldObject[@"oldIntCol"], @"Deleted column should be accessible on old object.");
        XCTAssertThrows(oldObject[@"intCol"], @"New column should not be accessible on old object.");
        XCTAssertEqual([oldObject[@"oldIntCol"] intValue], 1, @"Deleted column value is correct.");
        XCTAssertNoThrow(newObject[@"intCol"], @"New column is accessible on new object.");
        XCTAssertThrows(newObject[@"oldIntCol"], @"Old column should not be accessible on old object.");
        XCTAssertEqual([newObject[@"intCol"] intValue], 0, @"New column value is uninitialized.");
    };

    // apply migration
    [RLMRealm setSchemaVersion:1 forRealmAtPath:RLMTestRealmPath() withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
        XCTAssertEqual(oldSchemaVersion, 0U, @"Initial schema version should be 0");
        [migration enumerateObjects:MigrationObject.className block:migrateObjectBlock];
    }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];

    // verify migration
    realm = [self realmWithTestPath];
    MigrationObject *mig1 = [MigrationObject allObjectsInRealm:realm][1];
    XCTAssertThrows(mig1[@"oldIntCol"], @"Deleted column should no longer be accessible.");
    XCTAssertEqual(0U, [mig1.objectSchema.properties[0] column]);
    XCTAssertEqual(1U, [mig1.objectSchema.properties[1] column]);
}

- (void)testChangePropertyType {
    // make string an int
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationObject.class];
    RLMProperty *stringCol = objectSchema.properties[1];
    stringCol.type = RLMPropertyTypeInt;
    stringCol.objcType = 'i';

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationObject.className withObject:@[@1, @1]];
    [realm createObject:MigrationObject.className withObject:@[@2, @2]];
    [realm commitWriteTransaction];

    // apply migration
    [RLMRealm setSchemaVersion:1 forRealmAtPath:RLMTestRealmPath() withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
        XCTAssertEqual(oldSchemaVersion, 0U, @"Initial schema version should be 0");
        [migration enumerateObjects:MigrationObject.className
                                       block:^(RLMObject *oldObject, RLMObject *newObject) {
            NSNumber *intObj = oldObject[@"stringCol"];
            XCTAssert([intObj isKindOfClass:NSNumber.class], @"Old stringCol should be int");
            newObject[@"stringCol"] = intObj.stringValue;
        }];
    }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];

    // verify migration
    realm = [self realmWithTestPath];
    MigrationObject *mig1 = [MigrationObject allObjectsInRealm:realm][1];
    XCTAssertEqualObjects(mig1[@"stringCol"], @"2", @"stringCol should be string after migration.");
}

- (void)testPrimaryKeyMigration {
    // make string an int
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationPrimaryKeyObject.class];
    objectSchema.primaryKeyProperty.isPrimary = NO;
    objectSchema.primaryKeyProperty = nil;

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationPrimaryKeyObject.className withObject:@[@1]];
    [realm createObject:MigrationPrimaryKeyObject.className withObject:@[@1]];
    [realm commitWriteTransaction];

    // apply migration
    [RLMRealm setSchemaVersion:1
                forRealmAtPath:RLMTestRealmPath()
            withMigrationBlock:^(__unused RLMMigration *migration, __unused NSUInteger oldSchemaVersion) {}];
    XCTAssertThrows([RLMRealm migrateRealmAtPath:RLMTestRealmPath()],
                    @"Migration should throw due to duplicate primary keys)");

    [RLMRealm setSchemaVersion:1
                forRealmAtPath:RLMTestRealmPath()
            withMigrationBlock:^(__unused RLMMigration *migration, __unused NSUInteger oldSchemaVersion) {
        __block int objectID = 0;
        [migration enumerateObjects:@"MigrationPrimaryKeyObject" block:^(__unused RLMObject *oldObject, RLMObject *newObject) {
            newObject[@"intCol"] = @(objectID++);
        }];
    }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];
}

- (void)testRemovePrimaryKeyMigration {
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationPrimaryKeyObject.class];

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationPrimaryKeyObject.className withObject:@[@1]];
    [realm createObject:MigrationPrimaryKeyObject.className withObject:@[@2]];
    [realm commitWriteTransaction];

    objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationPrimaryKeyObject.class];
    objectSchema.primaryKeyProperty.isPrimary = NO;
    objectSchema.primaryKeyProperty = nil;

    // needs a no-op migration
    XCTAssertThrows([self realmWithSingleObject:objectSchema]);

    [RLMRealm setSchemaVersion:1
                forRealmAtPath:RLMTestRealmPath()
            withMigrationBlock:^(__unused RLMMigration *migration, __unused NSUInteger oldSchemaVersion) { }];

    XCTAssertNoThrow([self realmWithSingleObject:objectSchema]);
}

- (void)testStringPrimaryKeyMigration {
    // make string an int
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationStringPrimaryKeyObject.class];
    objectSchema.primaryKeyProperty.isPrimary = NO;
    objectSchema.primaryKeyProperty = nil;

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationStringPrimaryKeyObject.className withObject:@[@"1"]];
    [realm createObject:MigrationStringPrimaryKeyObject.className withObject:@[@"2"]];
    [realm commitWriteTransaction];

    // apply migration
    [RLMRealm setSchemaVersion:1
                forRealmAtPath:RLMTestRealmPath()
            withMigrationBlock:^(__unused RLMMigration *migration, __unused NSUInteger oldSchemaVersion) {
        [migration enumerateObjects:@"MigrationStringPrimaryKeyObject" block:^(__unused RLMObject *oldObject, RLMObject *newObject) {
            newObject[@"stringCol"] = [[NSUUID UUID] UUIDString];
        }];
    }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];
}

- (void)testStringPrimaryKeyNoIndexMigration {
    // make string an int
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationStringPrimaryKeyObject.class];

    // create without search index
    objectSchema.primaryKeyProperty.attributes = 0;

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationStringPrimaryKeyObject.className withObject:@[@"1"]];
    [realm createObject:MigrationStringPrimaryKeyObject.className withObject:@[@"2"]];
    [realm commitWriteTransaction];

    // apply migration
    [RLMRealm setSchemaVersion:1
                forRealmAtPath:RLMTestRealmPath()
            withMigrationBlock:^(__unused RLMMigration *migration, __unused NSUInteger oldSchemaVersion) {
        [migration enumerateObjects:@"MigrationStringPrimaryKeyObject" block:^(__unused RLMObject *oldObject, RLMObject *newObject) {
            newObject[@"stringCol"] = [[NSUUID UUID] UUIDString];
        }];
    }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];
}

- (void)testIntPrimaryKeyNoIndexMigration {
    // make string an int
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationPrimaryKeyObject.class];

    // create without search index
    objectSchema.primaryKeyProperty.attributes = 0;

    // create realm with old schema and populate
    @autoreleasepool {
        RLMRealm *realm = [self realmWithSingleObject:objectSchema];
        [realm beginWriteTransaction];
        [realm createObject:MigrationPrimaryKeyObject.className withObject:@[@1]];
        [realm createObject:MigrationPrimaryKeyObject.className withObject:@[@2]];
        [realm commitWriteTransaction];

        XCTAssertFalse(realm.schema[MigrationPrimaryKeyObject.className].table->has_search_index(0));
    }

    // apply migration
    [RLMRealm setSchemaVersion:1 forRealmAtPath:RLMTestRealmPath() withMigrationBlock:^(__unused RLMMigration *migration, __unused NSUInteger oldSchemaVersion) { }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];

    // check that column is now indexed
    RLMRealm *realm = [self realmWithTestPath];
    XCTAssertTrue(realm.schema[MigrationPrimaryKeyObject.className].table->has_search_index(0));

    // verify that old data still exists
    RLMResults *objects = [MigrationPrimaryKeyObject allObjectsInRealm:realm];
    XCTAssertEqual(1, [objects[0] intCol]);
    XCTAssertEqual(2, [objects[1] intCol]);
}

- (void)testDuplicatePrimaryKeyMigration {
    // make string an int
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationPrimaryKeyObject.class];
    objectSchema.primaryKeyProperty.isPrimary = NO;
    objectSchema.primaryKeyProperty = nil;

    // create realm with old schema and populate
    RLMRealm *realm = [self realmWithSingleObject:objectSchema];
    [realm beginWriteTransaction];
    [realm createObject:MigrationPrimaryKeyObject.className withObject:@[@1]];
    [realm createObject:MigrationPrimaryKeyObject.className withObject:@[@1]];
    [realm commitWriteTransaction];

    // apply bad migration
    [RLMRealm setSchemaVersion:1
                forRealmAtPath:RLMTestRealmPath()
            withMigrationBlock:^(__unused RLMMigration *migration, __unused NSUInteger oldSchemaVersion) {}];
    XCTAssertThrows([RLMRealm migrateRealmAtPath:RLMTestRealmPath()], @"Migration should throw due to duplicate primary keys)");

    // apply good migration
    [RLMRealm setSchemaVersion:1
                forRealmAtPath:RLMTestRealmPath()
            withMigrationBlock:^(RLMMigration *migration, __unused NSUInteger oldSchemaVersion) {
        NSMutableSet *seen = [NSMutableSet set];
        __block bool duplicateDeleted = false;
        [migration enumerateObjects:@"MigrationPrimaryKeyObject" block:^(__unused RLMObject *oldObject, RLMObject *newObject) {
           if ([seen containsObject:newObject[@"intCol"]]) {
               duplicateDeleted = true;
               [migration deleteObject:newObject];
           }
           else {
               [seen addObject:newObject[@"intCol"]];
           }
        }];
        XCTAssertEqual(true, duplicateDeleted);
    }];
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];

    // make sure deletion occurred
    XCTAssertEqual(1U, [[MigrationPrimaryKeyObject allObjectsInRealm:[RLMRealm realmWithPath:RLMTestRealmPath()]] count]);
}

- (void)testIncompleteMigrationIsRolledBack {
    // make string an int
    RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationPrimaryKeyObject.class];
    objectSchema.primaryKeyProperty.isPrimary = NO;
    objectSchema.primaryKeyProperty = nil;

    // create realm with old schema and populate
    @autoreleasepool {
        RLMRealm *realm = [self realmWithSingleObject:objectSchema];
        [realm beginWriteTransaction];
        [realm createObject:MigrationPrimaryKeyObject.className withObject:@[@1]];
        [realm createObject:MigrationPrimaryKeyObject.className withObject:@[@1]];
        [realm commitWriteTransaction];
    }

    // fail to apply migration
    [RLMRealm setSchemaVersion:1
                forRealmAtPath:RLMTestRealmPath()
            withMigrationBlock:^(__unused RLMMigration *migration, __unused NSUInteger oldSchemaVersion) {}];
    XCTAssertThrows([RLMRealm migrateRealmAtPath:RLMTestRealmPath()], @"Migration should throw due to duplicate primary keys)");

    // should still be able to open with pre-migration schema
    XCTAssertNoThrow([self realmWithSingleObject:objectSchema]);
}

- (void)testAddObjectDuringMigration {
    // initialize realm
    @autoreleasepool {
        [RLMRealm defaultRealm];
    }

    [RLMRealm setDefaultRealmSchemaVersion:1
                        withMigrationBlock:^(RLMMigration *migration, __unused NSUInteger oldSchemaVersion) {
        [migration createObject:StringObject.className withObject:@[@"string"]];
    }];

    // implicit migration
    XCTAssertEqual(1U, StringObject.allObjects.count);
}

- (void)testVersionNumberCanStaySameWithNoSchemaChanges {
    @autoreleasepool { [self realmWithTestPathAndSchema:[RLMSchema sharedSchema]]; }

    [RLMRealm setSchemaVersion:0
                forRealmAtPath:RLMTestRealmPath()
            withMigrationBlock:^(__unused RLMMigration *migration, __unused NSUInteger oldSchemaVersion) {}];
    XCTAssertNoThrow([RLMRealm migrateRealmAtPath:RLMTestRealmPath()]);
}

- (void)testMigrationIsAppliedWhenNeeded {
    @autoreleasepool {
        // make string an int
        RLMObjectSchema *objectSchema = [RLMObjectSchema schemaForObjectClass:MigrationObject.class];
        RLMProperty *stringCol = objectSchema.properties[1];
        stringCol.type = RLMPropertyTypeInt;
        stringCol.objcType = 'i';

        // create realm with old schema and populate
        RLMRealm *realm = [self realmWithSingleObject:objectSchema];
        [realm beginWriteTransaction];
        [realm createObject:MigrationObject.className withObject:@[@1, @1]];
        [realm commitWriteTransaction];
    }

    __block bool migrationApplied = false;
    [RLMRealm setSchemaVersion:1
                forRealmAtPath:RLMTestRealmPath()
            withMigrationBlock:^(RLMMigration *migration, __unused NSUInteger oldSchemaVersion) {
        [migration enumerateObjects:MigrationObject.className block:^(RLMObject *, RLMObject *newObject) {
            newObject[@"stringCol"] = @"";
        }];
        migrationApplied = true;
    }];

    // migration should be applied when opening realm
    [RLMRealm realmWithPath:RLMTestRealmPath()];
    XCTAssertEqual(true, migrationApplied);

    // applying migration at same version is no-op
    migrationApplied = false;
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];
    XCTAssertEqual(false, migrationApplied);

    // test version cant go down
    [RLMRealm setSchemaVersion:0
                forRealmAtPath:RLMTestRealmPath()
            withMigrationBlock:^(__unused RLMMigration *migration, __unused NSUInteger oldSchemaVersion) {}];
    XCTAssertThrows([RLMRealm migrateRealmAtPath:RLMTestRealmPath()]);
}

- (void)testVersionNumberCanStaySameWhenAddingObjectSchema {
    @autoreleasepool {
        // create realm with old schema and populate
        RLMRealm *realm = [self realmWithSingleObject:[RLMObjectSchema schemaForObjectClass:MigrationObject.class]];
        [realm beginWriteTransaction];
        [realm createObject:MigrationObject.className withObject:@[@1, @"1"]];
        [realm commitWriteTransaction];
    }
    XCTAssertNoThrow([RLMRealm realmWithPath:RLMTestRealmPath()]);
}

- (void)testRearrangeProperties {
    @autoreleasepool {
        // create object in default realm
        [[RLMRealm defaultRealm] transactionWithBlock:^{
            [CircleObject createInDefaultRealmWithObject:@[@"data", NSNull.null]];
        }];

        // create realm with the properties reversed
        RLMSchema *schema = [[RLMSchema sharedSchema] copy];
        RLMObjectSchema *objectSchema = schema[@"CircleObject"];
        objectSchema.properties = @[objectSchema.properties[1], objectSchema.properties[0]];

        RLMRealm *realm = [self realmWithTestPathAndSchema:schema];
        [realm beginWriteTransaction];
        [realm createObject:CircleObject.className withObject:@[NSNull.null, @"data"]];
        [realm commitWriteTransaction];
    }

    // migration should not be requried
    RLMRealm *realm = nil;
    XCTAssertNoThrow(realm = [self realmWithTestPath]);

    // accessors should work
    CircleObject *obj = [[CircleObject allObjectsInRealm:realm] firstObject];
    [realm beginWriteTransaction];
    XCTAssertNoThrow(obj.data = @"new data");
    XCTAssertNoThrow(obj.next = obj);
    [realm commitWriteTransaction];

    // open the default Realm and make sure accessors with alternate ordering work
    CircleObject *defaultObj = [[CircleObject allObjects] firstObject];
    XCTAssertEqualObjects(defaultObj.data, @"data");

    // test object from other realm still works
    XCTAssertEqualObjects(obj.data, @"new data");

    // verify schema for both objects
    NSArray *properties = defaultObj.objectSchema.properties;
    for (NSUInteger i = 0; i < properties.count; i++) {
        XCTAssertEqual([properties[i] column], i);
    }
    properties = obj.objectSchema.properties;
    for (NSUInteger i = 0; i < properties.count; i++) {
        XCTAssertEqual([properties[i] column], i);
    }
}

- (void)testMigrationDoesNotEffectOtherPaths {
    RLMRealm *defaultRealm = RLMRealm.defaultRealm;
    [RLMRealm migrateRealmAtPath:RLMTestRealmPath()];
    XCTAssertEqual(defaultRealm, RLMRealm.defaultRealm);
}

@end

