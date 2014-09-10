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

// Sortable Realm types
public protocol Sortable {}
extension NSDate: Sortable {}
extension Int16: Sortable {}
extension Int32: Sortable {}
extension Int: Sortable {}
extension Int64: Sortable {}
extension Float: Sortable {}
extension Double: Sortable {}

public typealias ArrayProperty = RLMArray

public extension ArrayProperty {

    public convenience init<T: Object>(_: T.Type) {
        self.init(objectClassName: RLMSwiftSupport.demangleClassName(NSStringFromClass(T.self)))
    }

    public func realmArray<T: Object>(_: T.Type) -> RealmArray<T> {
        return RealmArray<T>(rlmArray: self)
    }
}

public class RealmArray<T: Object>: SequenceType, Printable {
    var rlmArray: RLMArray
    public var count: UInt { return rlmArray.count }
    public var readOnly: Bool { return rlmArray.readOnly }
    public var realm: Realm { return Realm(rlmRealm: rlmArray.realm) }

    public var description: String { return rlmArray.description }

    public init() {
        rlmArray = RLMArray(objectClassName: RLMSwiftSupport.demangleClassName(NSStringFromClass(T.self)))
    }

    convenience init(rlmArray: RLMArray) {
        self.init()
        self.rlmArray = rlmArray
    }

    public subscript(index: UInt) -> T {
        get {
            return rlmArray[index] as T
        }
        set {
            return rlmArray[index] = newValue
        }
    }

    public func first() -> T? {
        return rlmArray.firstObject() as T?
    }

    public func last() -> T? {
        return rlmArray.lastObject() as T?
    }

    public func indexOf(object: T) -> UInt? {
        return rlmArray.indexOfObject(object)
    }

    public func indexWhere(predicate: NSPredicate) -> UInt? {
        return rlmArray.indexOfObjectWithPredicate(predicate)
    }

    // Swift query convenience functions

    public func indexWhere(predicateFormat: String, _ args: CVarArgType...) -> UInt {
        return rlmArray.indexOfObjectWhere(predicateFormat, args: getVaList(args))
    }

    public func objectsWhere(predicateFormat: String, _ args: CVarArgType...) -> RealmArray<T> {
        return RealmArray<T>(rlmArray: rlmArray.objectsWhere(predicateFormat, args: getVaList(args)))
    }

    public func objectsWhere(predicate: NSPredicate) -> RealmArray<T> {
        return RealmArray<T>(rlmArray: rlmArray.objectsWithPredicate(predicate))
    }

    public func arraySortedByProperty(property: String, ascending: Bool) -> RealmArray<T> {
        return RealmArray<T>(rlmArray: rlmArray.arraySortedByProperty(property, ascending: ascending))
    }

    public func minOfProperty<U: Sortable>(property: String) -> U {
        return rlmArray.minOfProperty(property) as U
    }

    public func maxOfProperty<U: Sortable>(property: String) -> U {
        return rlmArray.maxOfProperty(property) as U
    }

    public func sumOfProperty(property: String) -> Double {
        return rlmArray.sumOfProperty(property) as Double
    }

    public func averageOfProperty(property: String) -> Double {
        return rlmArray.averageOfProperty(property) as Double
    }

    public func JSONString() -> String {
        return rlmArray.JSONString()
    }

    public func generate() -> GeneratorOf<T> {
        var i: UInt = 0
        return GeneratorOf<T>() {
            if (i >= self.rlmArray.count) {
                return .None
            } else {
                return self.rlmArray[i++] as? T
            }
        }
    }

    public func add(object: T) {
        rlmArray.addObject(object)
    }

    public func add(objects: [T]) {
        rlmArray.addObjectsFromArray(objects)
    }

    public func insert(object: T, atIndex index: UInt) {
        rlmArray.insertObject(object, atIndex: index)
    }

    public func remove(index: UInt) {
        rlmArray.removeObjectAtIndex(index)
    }

    public func remove(object: T) {
        if let index = indexOf(object) {
            remove(index)
        }
    }

    public func removeLast() {
        rlmArray.removeLastObject()
    }

    public func removeAll() {
        rlmArray.removeAllObjects()
    }

    public func replace(index: UInt, object: T) {
        rlmArray.replaceObjectAtIndex(index, withObject: object)
    }
}
