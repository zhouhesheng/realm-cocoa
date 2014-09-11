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

import Foundation

class Model : RLMObject {
    var foo : Int = 0
    dynamic var bar : Int = 0
}

class Sample : NSObject {
    var foo = 0
    dynamic var bar = 0
}

class Generic<T> {
    var val = 0
}

class VarLet : NSObject {
    var foo = Generic<Int>()
    let bar = Generic<Int>()
}




class Magic : NSObject { // aka Realm.Object
}

class QueryAttribute<T> {
    let column: Int

    init(type: AnyClass, propertyName: String) {
        // map type/property name to column index plus table
        column = 0
    }

    // has overloaded operators for query building
}

func Attribute<T: Magic, U>(x: T.Type, f: (T) -> U) -> QueryAttribute<U> {
    var propName: NSString? = ""
    f(RLMCreateAccessorRecorder(T.self as Magic.Type, nil, &propName) as T)
    return QueryAttribute(type: x, propertyName: propName!)
}


class Employee : Magic {
    var name = ""
    var age = 10
}

struct EmployeeProperties {
    static let name = Attribute(Employee.self) { $0.name }
    static let age = Attribute(Employee.self) { $0.age }
}


class Observer : NSObject {
    var sample = Sample()

    func test() {
        var b2 = Attribute(Employee.self) { $0.age }

        sample.addObserver(self, forKeyPath: "bar", options: nil, context: nil)
        sample.bar = 5

        sample.addObserver(self, forKeyPath: "foo", options: nil, context: nil)
        sample.foo = 5
    }

    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
        NSLog("change: \(change)")
    }
}

func stuff(var f : Sample -> Int) {
    NSLog("stuff")
}

@objc public class RLMSwiftSupport {
    public class func isSwiftClassName(className: NSString) -> Bool {
        return className.rangeOfString(".").location != NSNotFound
    }

    public class func demangleClassName(className: NSString) -> NSString {
        return className.substringFromIndex(className.rangeOfString(".").location + 1)
    }

    public class func schemaForObjectClass(aClass: AnyClass) -> RLMObjectSchema {
        var test = Observer()
        test.test()



        let obj = VarLet()
        dump(obj)
        let ref = reflect(obj)
        for i in 0..<ref.count {
            let f = ref[i]
            NSLog("\(f.0) \(f.1.disposition) \(f.1.count)")
            for i in 0..<f.1.count {
                let ff = f.1[i]
                NSLog("- \(ff.0) \(ff.1.disposition) \(ff.1.count)")
            }

            NSLog("get: \(obj.respondsToSelector(NSSelectorFromString(f.0)))")
            NSLog("set: \(obj.respondsToSelector(NSSelectorFromString(RLMGetSetterName(f.0))))")
        }

        var propertiesCount : CUnsignedInt = 0
        let propertiesInAClass : UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(obj.dynamicType, &propertiesCount)
        for var i = 0; i < Int(propertiesCount); i++ {
            NSLog("\(NSString(CString: property_getAttributes(propertiesInAClass[i]), encoding: NSUTF8StringEncoding))")

            var attrCount : CUnsignedInt = 0
            let attrs = property_copyAttributeList(propertiesInAClass[i], &attrCount)

            for var j = 0; j < Int(attrCount); ++j {
                NSLog("\(NSString(CString: attrs[j].value, encoding: NSUTF8StringEncoding))")
            }
        }


        let className = demangleClassName(NSStringFromClass(aClass))

        let swiftObject = (aClass as RLMObject.Type)()
        let reflection = reflect(swiftObject)
        let ignoredPropertiesForClass = aClass.ignoredProperties() as NSArray?

        var properties = [RLMProperty]()

        dump(swiftObject)
//        for var index=0; index<reflect(swiftObject).count; ++index {
//            println(reflect(swiftObject)[index].0 + ": "+reflect(swiftObject)[index].1.summary)
//        }

        // Skip the first property (super):
        // super is an implicit property on Swift objects
        for i in 1..<reflection.count {
            let propertyName = reflection[i].0
            if ignoredPropertiesForClass?.containsObject(propertyName) ?? false {
                continue
            }

            NSLog("\(reflection[i].0) \(reflection[i].1)")

            properties.append(createPropertyForClass(aClass,
                mirror: reflection[i].1,
                name: propertyName,
                attr: aClass.attributesForProperty(propertyName)))
        }

        return RLMObjectSchema(className: className as NSString?, objectClass: aClass, properties: properties)
    }

    class func createPropertyForClass(aClass: AnyClass,
        mirror: MirrorType,
        name: String,
        attr: RLMPropertyAttributes) -> RLMProperty {
            let valueType = mirror.valueType
            let (p, t) = { () -> (RLMProperty, String) in
                switch valueType {
                    // Detect basic types (including optional versions)
                case is Bool.Type, is Bool?.Type:
                    return (RLMProperty(name: name, type: .Bool, objectClassName: nil, attributes: attr), "c")
                case is Int.Type, is Int?.Type:
#if arch(x86_64) || arch(arm64)
                    let t = "l"
#else
                    let t = "i"
#endif
                    return (RLMProperty(name: name, type: .Int, objectClassName: nil, attributes: attr), t)
                case is Float.Type, is Float?.Type:
                    return (RLMProperty(name: name, type: .Float, objectClassName: nil, attributes: attr), "f")
                case is Double.Type, is Double?.Type:
                    return (RLMProperty(name: name, type: .Double, objectClassName: nil, attributes: attr), "d")
                case is String.Type, is String?.Type:
                    return (RLMProperty(name: name, type: .String, objectClassName: nil, attributes: attr), "S")
                case is NSData.Type, is NSData?.Type:
                    return (RLMProperty(name: name, type: .Data, objectClassName: nil, attributes: attr), "@\"NSData\"")
                case is NSDate.Type, is NSDate?.Type:
                    return (RLMProperty(name: name, type: .Date, objectClassName: nil, attributes: attr), "@\"NSDate\"")
                case let objectType as RLMObject.Type:
                    let mangledClassName = NSStringFromClass(objectType.self)
                    let objectClassName = self.demangleClassName(mangledClassName)
                    let typeEncoding = "@\"\(mangledClassName))\""
                    return (RLMProperty(name: name, type: .Object, objectClassName: objectClassName, attributes: attr), typeEncoding)
                case let c as RLMArray.Type:
                    let objectClassName = (mirror.value as RLMArray).objectClassName
                    return (RLMProperty(name: name, type: .Array, objectClassName: objectClassName, attributes: attr), "@\"RLMArray\"")
                default:
                    println("Can't persist property '\(name)' with incompatible type.\nAdd to ignoredPropertyNames: method to ignore.")
                    abort()
                }
            }()

            // create objc property
            let attr = objc_property_attribute_t(name: "T", value: t)
            class_addProperty(aClass, p.name, [attr], 1)
            return p
    }
}
