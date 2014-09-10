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

// MARK: Notifications

public enum Notification: String {
    case DidChange = "RLMRealmDidChangeNotification"
}

public typealias NotificationBlock = (notification: Notification, realm: Realm) -> Void

func rlmNotificationBlockFromNotificationBlock(notificationBlock: NotificationBlock) -> RLMNotificationBlock {
    return { rlmNotification, rlmRealm in
        return notificationBlock(notification: Notification.fromRaw(rlmNotification)!, realm: Realm(rlmRealm: rlmRealm))
    }
}

// MARK: Migrations

public func migrateDefaultRealm(block: MigrationBlock) {
    RLMRealm.migrateDefaultRealmWithBlock(rlmMigrationBlockFromMigrationBlock(block))
}

public func migrateRealm(path: String, block: MigrationBlock) {
    RLMRealm.migrateRealmAtPath(path, withBlock: rlmMigrationBlockFromMigrationBlock(block))
}

// MARK: Object Retrieval

public func objects<T: Object>(type: T.Type) -> RealmArray<T> {
    return RealmArray<T>(rlmArray: T.self.allObjectsInRealm(RLMRealm.defaultRealm()))
}

public func objects<T: Object>(type: T.Type, filter: String, args: CVarArgType...) -> RealmArray<T> {
    return RealmArray<T>(rlmArray: T.self.objectsInRealm(RLMRealm.defaultRealm(), `where`: filter, args: getVaList(args)))
}

public func objects<T: Object>(type: T.Type, filter: NSPredicate) -> RealmArray<T> {
    return RealmArray<T>(rlmArray: T.self.objectsInRealm(RLMRealm.defaultRealm(), withPredicate: filter))
}

// MARK: Default Realm Helpers

public func defaultRealmPath() -> String {
    return RLMRealm.defaultRealmPath()
}

public func defaultRealm() -> Realm {
    return Realm(rlmRealm: RLMRealm.defaultRealm())
}

public class Realm {
    // MARK: Properties

    var rlmRealm: RLMRealm
    public var path: String { return rlmRealm.path }
    public var readOnly: Bool { return rlmRealm.readOnly }
    public var schema: Schema { return Schema(rlmSchema: rlmRealm.schema) }
    public var autorefresh: Bool {
        get {
            return rlmRealm.autorefresh
        }
        set {
            rlmRealm.autorefresh = newValue
        }
    }

    // MARK: Initializers

    init(rlmRealm: RLMRealm) {
        self.rlmRealm = rlmRealm
    }

    public convenience init(path: String) {
        self.init(path: path, readOnly: false, error: nil)
    }

    public convenience init(path: String, readOnly readonly: Bool, error: NSErrorPointer) {
        self.init(rlmRealm: RLMRealm.realmWithPath(path, readOnly: readonly, error: error))
    }

    // MARK: In-Memory

    public class func useInMemoryDefaultRealm() {
        RLMRealm.useInMemoryDefaultRealm()
    }

    // MARK: Transactions

    public func transaction(block: (() -> Void)) {
        rlmRealm.transactionWithBlock(block)
    }

    public func beginWriteTransaction() {
        rlmRealm.beginWriteTransaction()
    }

    public func commitWriteTransaction() {
        rlmRealm.commitWriteTransaction()
    }

    // MARK: Refresh

    public func refresh() {
        rlmRealm.refresh()
    }

    // MARK: Mutating

    public func add(object: Object) {
        rlmRealm.addObject(object)
    }

    public func add(objects: [Object]) {
        rlmRealm.addObjectsFromArray(objects)
    }

    public func delete(object: Object) {
        rlmRealm.deleteObject(object)
    }

    // MARK: Notifications

    public func addNotificationBlock(block: NotificationBlock) -> NotificationToken {
        return rlmRealm.addNotificationBlock(rlmNotificationBlockFromNotificationBlock(block))
    }

    public func removeNotification(notificationToken: NotificationToken) {
        rlmRealm.removeNotification(notificationToken)
    }

    // MARK: Object Retrieval

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
