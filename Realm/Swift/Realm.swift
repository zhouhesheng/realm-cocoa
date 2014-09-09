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

public func migrateDefaultRealmWithBlock(block: MigrationBlock) {
    RLMRealm.migrateDefaultRealmWithBlock(block)
}

public func migrateRealmAtPath(path: String, withBlock block: MigrationBlock) {
    RLMRealm.migrateRealmAtPath(path, withBlock: block)
}

public func objects<T: Object>(type: T.Type) -> RealmArray<T> {
    return RealmArray<T>(rlmArray: T.self.allObjectsInRealm(RLMRealm.defaultRealm()))
}

public func objects<T: Object>(type: T.Type, predicateFormat: String, args: CVarArgType...) -> RealmArray<T> {
    return RealmArray<T>(rlmArray: T.self.objectsInRealm(RLMRealm.defaultRealm(), `where`: predicateFormat, args: getVaList(args)))
}

public func objects<T: Object>(type: T.Type, withPredicate predicate: NSPredicate) -> RealmArray<T> {
    return RealmArray<T>(rlmArray: T.self.objectsInRealm(RLMRealm.defaultRealm(), withPredicate: predicate))
}

public class Realm {
    var rlmRealm: RLMRealm
    public var path: String { return rlmRealm.path }
    public var readOnly: Bool { return rlmRealm.readOnly }
    public var schema: Schema { return rlmRealm.schema }
    public var autorefresh: Bool {
        get {
            return rlmRealm.autorefresh
        }
        set {
            rlmRealm.autorefresh = newValue
        }
    }

    public class func defaultRealmPath() -> String {
        return RLMRealm.defaultRealmPath()
    }

    public class func defaultRealm() -> Realm {
        return Realm(rlmRealm: RLMRealm.defaultRealm())
    }

    init(rlmRealm: RLMRealm) {
        self.rlmRealm = rlmRealm
    }

    public convenience init(path: String) {
        self.init(path: path, readOnly: false, error: nil)
    }

    public convenience init(path: String, readOnly readonly: Bool, error: NSErrorPointer) {
        self.init(rlmRealm: RLMRealm.realmWithPath(path, readOnly: readonly, error: error))
    }

    public class func useInMemoryDefaultRealm() {
        RLMRealm.useInMemoryDefaultRealm()
    }

    public func transactionWithBlock(block: (() -> Void)) {
        rlmRealm.transactionWithBlock(block)
    }

    public func beginWriteTransaction() {
        rlmRealm.beginWriteTransaction()
    }

    public func commitWriteTransaction() {
        rlmRealm.commitWriteTransaction()
    }

    public func refresh() {
        rlmRealm.refresh()
    }

    public func addObject(object: Object) {
        rlmRealm.addObject(object)
    }

    public func addObjects(objects: [Object]) {
        rlmRealm.addObjectsFromArray(objects)
    }

    public func deleteObject(object: Object) {
        rlmRealm.deleteObject(object)
    }

    public func addNotificationBlock(block: NotificationBlock) -> NotificationToken {
        return rlmRealm.addNotificationBlock(block)
    }

    public func removeNotification(notificationToken: NotificationToken) {
        rlmRealm.removeNotification(notificationToken)
    }

    public func objects<T: Object>(type: T.Type) -> RealmArray<T> {
        return RealmArray<T>(rlmArray: T.self.allObjectsInRealm(rlmRealm))
    }

    public func objects<T: Object>(type: T.Type, _ predicateFormat: String, _ args: CVarArgType...) -> RealmArray<T> {
        return RealmArray<T>(rlmArray: T.self.objectsInRealm(rlmRealm, `where`: predicateFormat, args: getVaList(args)))
    }

    public func objects<T: Object>(type: T.Type, withPredicate predicate: NSPredicate) -> RealmArray<T> {
        return RealmArray<T>(rlmArray: T.self.objectsInRealm(rlmRealm, withPredicate: predicate))
    }
}
