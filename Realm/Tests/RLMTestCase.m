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

@interface RLMRealm ()
+ (instancetype)realmWithPath:(NSString *)path
                          key:(NSData *)key
                     readOnly:(BOOL)readonly
                     inMemory:(BOOL)inMemory
                      dynamic:(BOOL)dynamic
                       schema:(RLMSchema *)customSchema
                        error:(NSError **)outError;
+ (void)resetRealmState;
@end

NSString *RLMRealmPathForFile(NSString *fileName) {
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
#else
    return fileName;
#endif
}

NSString *RLMDefaultRealmPath() {
#if TARGET_OS_IPHONE
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
#else
    NSString *path = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    path = [path stringByAppendingPathComponent:[[[NSBundle mainBundle] executablePath] lastPathComponent]];
#endif
    return [path stringByAppendingPathComponent:@"default.realm"];
}

NSString *RLMTestRealmPath() {
    return RLMRealmPathForFile(@"test.realm");
}

static NSString *RLMLockPath(NSString *path) {
    return [path stringByAppendingString:@".lock"];
}

static void RLMDeleteRealmFilesAtPath(NSString *path) {
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        @throw [NSException exceptionWithName:@"RLMTestException" reason:@"Unable to delete realm" userInfo:nil];
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:RLMLockPath(path) error:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:RLMLockPath(path)]) {
        @throw [NSException exceptionWithName:@"RLMTestException" reason:@"Unable to delete realm" userInfo:nil];
    }
}


@implementation RLMTestCase

- (void)setUp
{
    [super setUp];
    [self deleteFiles];
}

- (void)tearDown
{
    [super tearDown];
    [self deleteFiles];
}

- (void)deleteFiles {
    // Clear cache
    [RLMRealm resetRealmState];
    
    // Delete Realm files
    RLMDeleteRealmFilesAtPath(RLMDefaultRealmPath());
    RLMDeleteRealmFilesAtPath(RLMTestRealmPath());
}

- (void)invokeTest
{
    [self setUp];
    @autoreleasepool {
        [super invokeTest];
    }
    [self tearDown];
}

- (RLMRealm *)realmWithTestPath
{
    return [RLMRealm realmWithPath:RLMTestRealmPath() readOnly:NO error:nil];
}

- (RLMRealm *)realmWithTestPathAndSchema:(RLMSchema *)schema {
    return [RLMRealm realmWithPath:RLMTestRealmPath() key:nil readOnly:NO inMemory:NO dynamic:YES schema:schema error:nil];
}

- (void)waitForNotification:(NSString *)expectedNote realm:(RLMRealm *)realm block:(dispatch_block_t)block {
    XCTestExpectation *notificationFired = [self expectationWithDescription:@"notification fired"];
    RLMNotificationToken *token = [realm addNotificationBlock:^(__unused NSString *note, RLMRealm *realm) {
        XCTAssertNotNil(realm, @"Realm should not be nil");
        if (note == expectedNote) {
            [notificationFired fulfill];
        }
    }];

    dispatch_queue_t queue = dispatch_queue_create("background", 0);
    dispatch_async(queue, block);

    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    // wait for queue to finish
    dispatch_sync(queue, ^{});

    [realm removeNotification:token];
}

@end

