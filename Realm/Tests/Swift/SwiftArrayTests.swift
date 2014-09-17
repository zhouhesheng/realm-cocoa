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

import XCTest
import Realm
import TestFramework

class SwiftArrayTests: SwiftTestCase {

    // Swift models

    func testFastEnumeration() {
        let realm = realmWithTestPath()

        realm.beginWrite()

        let dateMinInput = NSDate()
        let dateMaxInput = dateMinInput.dateByAddingTimeInterval(1000)

        SwiftAggregateObject.createInRealm(realm, withObject: [10, 1.2 as Float, 0 as Double, true, dateMinInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [10, 0 as Float, 2.5 as Double, false, dateMaxInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [10, 1.2 as Float, 0 as Double, true, dateMinInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [10, 0 as Float, 2.5 as Double, false, dateMaxInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [10, 1.2 as Float, 0 as Double, true, dateMinInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [10, 0 as Float, 2.5 as Double, false, dateMaxInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [10, 1.2 as Float, 0 as Double, true, dateMinInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [10, 0 as Float, 2.5 as Double, false, dateMaxInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [10, 1.2 as Float, 0 as Double, true, dateMinInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [10, 1.2 as Float, 0 as Double, true, dateMinInput])

        realm.commitWrite()

        let result = realm.objects(SwiftAggregateObject).filter("intCol < %d", 100)
        XCTAssertEqual(result.count, 10, "10 objects added")

        var totalSum = 0

        for ao in result {
            totalSum += ao.intCol
        }

        XCTAssertEqual(totalSum, 100, "total sum should be 100")
    }

    func testReadOnly() {
        let realm = realmWithTestPath()

        realm.beginWrite()
        let obj = SwiftStringObject.createInRealm(realm, withObject: ["name"])
        realm.commitWrite()

        let array = realm.objects(SwiftStringObject)
        XCTAssertTrue(array.readOnly, "Array returned from query should be readonly")
    }

    func testObjectAggregate() {
        let realm = realmWithTestPath()

        realm.beginWrite()

        let dateMinInput = NSDate()
        let dateMaxInput = dateMinInput.dateByAddingTimeInterval(1000)

        SwiftAggregateObject.createInRealm(realm, withObject: [0, 1.2 as Float, 0 as Double, true, dateMinInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [1, 0 as Float, 2.5 as Double, false, dateMaxInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [0, 1.2 as Float, 0 as Double, true, dateMinInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [1, 0 as Float, 2.5 as Double, false, dateMaxInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [0, 1.2 as Float, 0 as Double, true, dateMinInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [1, 0 as Float, 2.5 as Double, false, dateMaxInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [0, 1.2 as Float, 0 as Double, true, dateMinInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [1, 0 as Float, 2.5 as Double, false, dateMaxInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [0, 1.2 as Float, 0 as Double, true, dateMinInput])
        SwiftAggregateObject.createInRealm(realm, withObject: [0, 1.2 as Float, 0 as Double, true, dateMinInput])

        realm.commitWrite()

        let noArray = realm.objects(SwiftAggregateObject).filter("boolCol == NO")
        let yesArray = realm.objects(SwiftAggregateObject).filter("boolCol == YES")

        // SUM ::::::::::::::::::::::::::::::::::::::::::::::
        // Test int sum
        XCTAssertEqual(noArray.sum("intCol"), 4, "Sum should be 4")
        XCTAssertEqual(yesArray.sum("intCol"), 0, "Sum should be 0")

        // Test float sum
        XCTAssertEqualWithAccuracy(noArray.sum("floatCol"), 0, 0.1, "Sum should be 0.0")
        XCTAssertEqualWithAccuracy(yesArray.sum("floatCol"), 7.2, 0.1, "Sum should be 7.2")

        // Test double sum
        XCTAssertEqualWithAccuracy(noArray.sum("doubleCol"), 10, 0.1, "Sum should be 10.0")
        XCTAssertEqualWithAccuracy(yesArray.sum("doubleCol"), 0, 0.1, "Sum should be 0.0")

        // Average ::::::::::::::::::::::::::::::::::::::::::::::
        // Test int average
        XCTAssertEqualWithAccuracy(noArray.average("intCol"), 1, 0.1, "Average should be 1.0")
        XCTAssertEqualWithAccuracy(yesArray.average("intCol"), 0, 0.1, "Average should be 0.0")

        // Test float average
        XCTAssertEqualWithAccuracy(noArray.average("floatCol"), 0, 0.1, "Average should be 0.0")
        XCTAssertEqualWithAccuracy(yesArray.average("floatCol"), 1.2, 0.1, "Average should be 1.2")

        // Test double average
        XCTAssertEqualWithAccuracy(noArray.average("doubleCol"), 2.5, 0.1, "Average should be 2.5")
        XCTAssertEqualWithAccuracy(yesArray.average("doubleCol"), 0, 0.1, "Average should be 0.0")

        // MIN ::::::::::::::::::::::::::::::::::::::::::::::
        // Test int min
//        var min = noArray.min("intCol")
//        XCTAssertEqual(min, 1, "Minimum should be 1")
//        min = yesArray.min("intCol")
//        XCTAssertEqual(min, 0, "Minimum should be 0")
//
//        // Test float min
//        min = noArray.min("floatCol")
//        XCTAssertEqualWithAccuracy(min, 0, 0.1, "Minimum should be 0.0f")
//        min = yesArray.min("floatCol")
//        XCTAssertEqualWithAccuracy(min, 1.2, 0.1, "Minimum should be 1.2f")
//
//        // Test double min
//        min = noArray.min("doubleCol")
//        XCTAssertEqualWithAccuracy(min, 2.5, 0.1, "Minimum should be 1.5")
//        min = yesArray.min("doubleCol")
//        XCTAssertEqualWithAccuracy(min, 0, 0.1, "Minimum should be 0.0")
//
//        // Test date min
//        var dateMinOutput = noArray.min("dateCol") as NSDate
//        XCTAssertEqualWithAccuracy(dateMinOutput.timeIntervalSince1970, dateMaxInput.timeIntervalSince1970, 1, "Minimum should be dateMaxInput")
//        dateMinOutput = yesArray.min("dateCol") as NSDate
//        XCTAssertEqualWithAccuracy(dateMinOutput.timeIntervalSince1970, dateMinInput.timeIntervalSince1970, 1, "Minimum should be dateMinInput")
//
//        // MAX ::::::::::::::::::::::::::::::::::::::::::::::
//        // Test int max
//        var max = noArray.max("intCol") as NSNumber
//        XCTAssertEqual(max.integerValue, 1, "Maximum should be 8")
//        max = yesArray.max("intCol") as NSNumber
//        XCTAssertEqual(max.integerValue, 0, "Maximum should be 10")
//
//        // Test float max
//        max = noArray.max("floatCol") as NSNumber
//        XCTAssertEqualWithAccuracy(max.floatValue, 0, 0.1, "Maximum should be 0.0f")
//        max = yesArray.max("floatCol") as NSNumber
//        XCTAssertEqualWithAccuracy(max.floatValue, 1.2, 0.1, "Maximum should be 1.2f")
//
//        // Test double max
//        max = noArray.max("doubleCol") as NSNumber
//        XCTAssertEqualWithAccuracy(max.doubleValue, 2.5, 0.1, "Maximum should be 3.5")
//        max = yesArray.max("doubleCol") as NSNumber
//        XCTAssertEqualWithAccuracy(max.doubleValue, 0, 0.1, "Maximum should be 0.0")
//
//        // Test date max
//        var dateMaxOutput = noArray.max("dateCol") as NSDate
//        XCTAssertEqualWithAccuracy(dateMaxOutput.timeIntervalSince1970, dateMaxInput.timeIntervalSince1970, 1, "Maximum should be dateMaxInput")
//        dateMaxOutput = yesArray.max("dateCol") as NSDate
//        XCTAssertEqualWithAccuracy(dateMaxOutput.timeIntervalSince1970, dateMinInput.timeIntervalSince1970, 1, "Maximum should be dateMinInput")
    }

    func testArrayDescription() {
        let realm = realmWithTestPath()

        realm.beginWrite()

        for i in 0..<1012 {
            let person = SwiftEmployeeObject()
            person.name = "Mary"
            person.age = 24
            person.hired = true
            realm.add(person)
        }

        realm.commitWrite()

        let description = realm.objects(SwiftEmployeeObject).description

        XCTAssertTrue((description as NSString).rangeOfString("name").location != Foundation.NSNotFound, "property names should be displayed when calling \"description\" on RLMArray")
        XCTAssertTrue((description as NSString).rangeOfString("Mary").location != Foundation.NSNotFound, "property values should be displayed when calling \"description\" on RLMArray")

        XCTAssertTrue((description as NSString).rangeOfString("age").location != Foundation.NSNotFound, "property names should be displayed when calling \"description\" on RLMArray")
        XCTAssertTrue((description as NSString).rangeOfString("24").location != Foundation.NSNotFound, "property values should be displayed when calling \"description\" on RLMArray")

        XCTAssertTrue((description as NSString).rangeOfString("12 objects skipped").location != Foundation.NSNotFound, "'12 objects skipped' should be displayed when calling \"description\" on RLMArray")
    }

    func testDeleteLinksAndObjectsInArray() {
        let realm = realmWithTestPath()

        realm.beginWrite()

        let po1 = SwiftEmployeeObject()
        po1.age = 40
        po1.name = "Joe"
        po1.hired = true

        let po2 = SwiftEmployeeObject()
        po2.age = 30
        po2.name = "John"
        po2.hired = false

        let po3 = SwiftEmployeeObject()
        po3.age = 25
        po3.name = "Jill"
        po3.hired = true

        realm.add(po1)
        realm.add(po2)
        realm.add(po3)

        let company = SwiftCompanyObject()
        realm.add(company)
        // FIXME: implement +=
//        company.employees += realm.objects(SwiftEmployeeObject)

        realm.commitWrite()

        let peopleInCompany = company.employees
        XCTAssertEqual(peopleInCompany.count, 3, "No links should have been deleted")

        realm.beginWrite()
        peopleInCompany.remove(1) // Should delete link to employee
        realm.commitWrite()

        XCTAssertEqual(peopleInCompany.count, 2, "link deleted when accessing via links")

        var test = peopleInCompany[0]!
        XCTAssertEqual(test.age, po1.age, "Should be equal")
        XCTAssertEqual(test.name, po1.name, "Should be equal")
        XCTAssertEqual(test.hired, po1.hired, "Should be equal")
        // XCTAssertEqual(test, po1, "Should be equal") //FIXME, should work. Asana : https://app.asana.com/0/861870036984/13123030433568

        test = peopleInCompany[1]!
        XCTAssertEqual(test.age, po3.age, "Should be equal")
        XCTAssertEqual(test.name, po3.name, "Should be equal")
        XCTAssertEqual(test.hired, po3.hired, "Should be equal")
        // XCTAssertEqual(test, po3, "Should be equal") //FIXME, should work. Asana : https://app.asana.com/0/861870036984/13123030433568

        realm.beginWrite()
        peopleInCompany.removeLast()
        XCTAssertEqual(peopleInCompany.count, 1, "1 remaining link")
        peopleInCompany.replace(0, object: po2)
        XCTAssertEqual(peopleInCompany.count, 1, "1 link replaced")
        peopleInCompany.insert(po1, atIndex: 0)
        XCTAssertEqual(peopleInCompany.count, 2, "2 links")
        peopleInCompany.removeAll()
        XCTAssertEqual(peopleInCompany.count, 0, "0 remaining links")
        realm.commitWrite()
    }

    // Objective-C models

    func testFastEnumeration_objc() {
        let realm = realmWithTestPath()

        realm.beginWrite()

        let dateMinInput = NSDate()
        let dateMaxInput = dateMinInput.dateByAddingTimeInterval(1000)

        AggregateObject.createInRealm(realm, withObject: [10, 1.2 as Float, 0 as Double, true, dateMinInput])
        AggregateObject.createInRealm(realm, withObject: [10, 0 as Float, 2.5 as Double, false, dateMaxInput])
        AggregateObject.createInRealm(realm, withObject: [10, 1.2 as Float, 0 as Double, true, dateMinInput])
        AggregateObject.createInRealm(realm, withObject: [10, 0 as Float, 2.5 as Double, false, dateMaxInput])
        AggregateObject.createInRealm(realm, withObject: [10, 1.2 as Float, 0 as Double, true, dateMinInput])
        AggregateObject.createInRealm(realm, withObject: [10, 0 as Float, 2.5 as Double, false, dateMaxInput])
        AggregateObject.createInRealm(realm, withObject: [10, 1.2 as Float, 0 as Double, true, dateMinInput])
        AggregateObject.createInRealm(realm, withObject: [10, 0 as Float, 2.5 as Double, false, dateMaxInput])
        AggregateObject.createInRealm(realm, withObject: [10, 1.2 as Float, 0 as Double, true, dateMinInput])
        AggregateObject.createInRealm(realm, withObject: [10, 1.2 as Float, 0 as Double, true, dateMinInput])

        realm.commitWrite()

        let result = realm.objects(AggregateObject).filter("intCol < %d", 100)
        XCTAssertEqual(result.count, 10, "10 objects added")

        var totalSum: CInt = 0

        for ao in result {
            totalSum += ao.intCol
        }

        XCTAssertEqual(totalSum, 100, "total sum should be 100")
    }

    func testReadOnly_objc() {
        let realm = realmWithTestPath()

        realm.beginWrite()
        let obj = StringObject.createInRealm(realm, withObject: ["name"])
        realm.commitWrite()

        let array = realm.objects(StringObject)
        XCTAssertTrue(array.readOnly, "Array returned from query should be readonly")
    }

    func testObjectAggregate_objc() {
        let realm = realmWithTestPath()

        realm.beginWrite()

        let dateMinInput = NSDate()
        let dateMaxInput = dateMinInput.dateByAddingTimeInterval(1000)

        AggregateObject.createInRealm(realm, withObject: [0, 1.2 as Float, 0 as Double, true, dateMinInput])
        AggregateObject.createInRealm(realm, withObject: [1, 0 as Float, 2.5 as Double, false, dateMaxInput])
        AggregateObject.createInRealm(realm, withObject: [0, 1.2 as Float, 0 as Double, true, dateMinInput])
        AggregateObject.createInRealm(realm, withObject: [1, 0 as Float, 2.5 as Double, false, dateMaxInput])
        AggregateObject.createInRealm(realm, withObject: [0, 1.2 as Float, 0 as Double, true, dateMinInput])
        AggregateObject.createInRealm(realm, withObject: [1, 0 as Float, 2.5 as Double, false, dateMaxInput])
        AggregateObject.createInRealm(realm, withObject: [0, 1.2 as Float, 0 as Double, true, dateMinInput])
        AggregateObject.createInRealm(realm, withObject: [1, 0 as Float, 2.5 as Double, false, dateMaxInput])
        AggregateObject.createInRealm(realm, withObject: [0, 1.2 as Float, 0 as Double, true, dateMinInput])
        AggregateObject.createInRealm(realm, withObject: [0, 1.2 as Float, 0 as Double, true, dateMinInput])

        realm.commitWrite()

        let noArray = realm.objects(AggregateObject).filter("boolCol == NO")
        let yesArray = realm.objects(AggregateObject).filter("boolCol == YES")

        // SUM ::::::::::::::::::::::::::::::::::::::::::::::
        // Test int sum
        XCTAssertEqual(noArray.sum("intCol"), 4, "Sum should be 4")
        XCTAssertEqual(yesArray.sum("intCol"), 0, "Sum should be 0")

        // Test float sum
        XCTAssertEqualWithAccuracy(noArray.sum("floatCol"), 0, 0.1, "Sum should be 0.0")
        XCTAssertEqualWithAccuracy(yesArray.sum("floatCol"), 7.2, 0.1, "Sum should be 7.2")

        // Test double sum
        XCTAssertEqualWithAccuracy(noArray.sum("doubleCol"), 10, 0.1, "Sum should be 10.0")
        XCTAssertEqualWithAccuracy(yesArray.sum("doubleCol"), 0, 0.1, "Sum should be 0.0")

        // Average ::::::::::::::::::::::::::::::::::::::::::::::
        // Test int average
        XCTAssertEqualWithAccuracy(noArray.average("intCol"), 1, 0.1, "Average should be 1.0")
        XCTAssertEqualWithAccuracy(yesArray.average("intCol"), 0, 0.1, "Average should be 0.0")

        // Test float average
        XCTAssertEqualWithAccuracy(noArray.average("floatCol"), 0, 0.1, "Average should be 0.0")
        XCTAssertEqualWithAccuracy(yesArray.average("floatCol"), 1.2, 0.1, "Average should be 1.2")

        // Test double average
        XCTAssertEqualWithAccuracy(noArray.average("doubleCol"), 2.5, 0.1, "Average should be 2.5")
        XCTAssertEqualWithAccuracy(yesArray.average("doubleCol"), 0, 0.1, "Average should be 0.0")

        // MIN ::::::::::::::::::::::::::::::::::::::::::::::
        // Test int min
//        var min = noArray.min("intCol") as NSNumber
//        XCTAssertEqual(min.intValue, 1, "Minimum should be 1")
//        min = yesArray.min("intCol") as NSNumber
//        XCTAssertEqual(min.intValue, 0, "Minimum should be 0")
//
//        // Test float min
//        min = noArray.min("floatCol") as NSNumber
//        XCTAssertEqualWithAccuracy(min.floatValue, 0, 0.1, "Minimum should be 0.0f")
//        min = yesArray.min("floatCol") as NSNumber
//        XCTAssertEqualWithAccuracy(min.floatValue, 1.2, 0.1, "Minimum should be 1.2f")
//
//        // Test double min
//        min = noArray.min("doubleCol") as NSNumber
//        XCTAssertEqualWithAccuracy(min.doubleValue, 2.5, 0.1, "Minimum should be 1.5")
//        min = yesArray.min("doubleCol") as NSNumber
//        XCTAssertEqualWithAccuracy(min.doubleValue, 0, 0.1, "Minimum should be 0.0")
//
//        // Test date min
//        var dateMinOutput = noArray.min("dateCol") as NSDate
//        XCTAssertEqualWithAccuracy(dateMinOutput.timeIntervalSince1970, dateMaxInput.timeIntervalSince1970, 1, "Minimum should be dateMaxInput")
//        dateMinOutput = yesArray.min("dateCol") as NSDate
//        XCTAssertEqualWithAccuracy(dateMinOutput.timeIntervalSince1970, dateMinInput.timeIntervalSince1970, 1, "Minimum should be dateMinInput")
//
//        // MAX ::::::::::::::::::::::::::::::::::::::::::::::
//        // Test int max
//        var max = noArray.max("intCol") as NSNumber
//        XCTAssertEqual(max.integerValue, 1, "Maximum should be 8")
//        max = yesArray.max("intCol") as NSNumber
//        XCTAssertEqual(max.integerValue, 0, "Maximum should be 10")
//
//        // Test float max
//        max = noArray.max("floatCol") as NSNumber
//        XCTAssertEqualWithAccuracy(max.floatValue, 0, 0.1, "Maximum should be 0.0f")
//        max = yesArray.max("floatCol") as NSNumber
//        XCTAssertEqualWithAccuracy(max.floatValue, 1.2, 0.1, "Maximum should be 1.2f")
//
//        // Test double max
//        max = noArray.max("doubleCol") as NSNumber
//        XCTAssertEqualWithAccuracy(max.doubleValue, 2.5, 0.1, "Maximum should be 3.5")
//        max = yesArray.max("doubleCol") as NSNumber
//        XCTAssertEqualWithAccuracy(max.doubleValue, 0, 0.1, "Maximum should be 0.0")
//
//        // Test date max
//        var dateMaxOutput = noArray.max("dateCol") as NSDate
//        XCTAssertEqualWithAccuracy(dateMaxOutput.timeIntervalSince1970, dateMaxInput.timeIntervalSince1970, 1, "Maximum should be dateMaxInput")
//        dateMaxOutput = yesArray.max("dateCol") as NSDate
//        XCTAssertEqualWithAccuracy(dateMaxOutput.timeIntervalSince1970, dateMinInput.timeIntervalSince1970, 1, "Maximum should be dateMinInput")
    }

    func testArrayDescription_objc() {
        let realm = realmWithTestPath()

        realm.beginWrite()

        for i in 0..<1012 {
            let person = EmployeeObject()
            person.name = "Mary"
            person.age = 24
            person.hired = true
            realm.add(person)
        }

        realm.commitWrite()

        let description = realm.objects(EmployeeObject).description
        XCTAssertTrue((description as NSString).rangeOfString("name").location != Foundation.NSNotFound, "property names should be displayed when calling \"description\" on RLMArray")
        XCTAssertTrue((description as NSString).rangeOfString("Mary").location != Foundation.NSNotFound, "property values should be displayed when calling \"description\" on RLMArray")

        XCTAssertTrue((description as NSString).rangeOfString("age").location != Foundation.NSNotFound, "property names should be displayed when calling \"description\" on RLMArray")
        XCTAssertTrue((description as NSString).rangeOfString("24").location != Foundation.NSNotFound, "property values should be displayed when calling \"description\" on RLMArray")

        XCTAssertTrue((description as NSString).rangeOfString("912 objects skipped").location != Foundation.NSNotFound, "'912 objects skipped' should be displayed when calling \"description\" on RLMArray")
    }

    func makeEmployee(realm: Realm, _ age: Int32, _ name: String, _ hired: Bool) -> EmployeeObject {
        let employee = EmployeeObject()
        employee.age = age
        employee.name = name
        employee.hired = hired
        realm.add(employee)
        return employee
    }

    func testDeleteLinksAndObjectsInArray_objc() {
        let realm = realmWithTestPath()

        realm.beginWrite()

        let po1 = makeEmployee(realm, 40, "Joe", true)
        let po2 = makeEmployee(realm, 30, "John", false)
        let po3 = makeEmployee(realm, 25, "Jill", true)

        let company = CompanyObject()
        company.name = "name"
        realm.add(company)
        company.employees = realm.objects(EmployeeObject).rlmArray

        realm.commitWrite()

        let peopleInCompany = company.employees
        XCTAssertEqual(peopleInCompany.count, 3, "No links should have been deleted")

        realm.beginWrite()
        peopleInCompany.removeObjectAtIndex(1) // Should delete link to employee
        realm.commitWrite()

        XCTAssertEqual(peopleInCompany.count, 2, "link deleted when accessing via links")

        var test = peopleInCompany[0] as EmployeeObject
        XCTAssertEqual(test.age, po1.age, "Should be equal")
        XCTAssertEqual(test.name!, po1.name!, "Should be equal")
        XCTAssertEqual(test.hired, po1.hired, "Should be equal")
        // XCTAssertEqual(test, po1, "Should be equal") //FIXME, should work. Asana : https://app.asana.com/0/861870036984/13123030433568

        test = peopleInCompany[1] as EmployeeObject
        XCTAssertEqual(test.age, po3.age, "Should be equal")
        XCTAssertEqual(test.name!, po3.name!, "Should be equal")
        XCTAssertEqual(test.hired, po3.hired, "Should be equal")
        // XCTAssertEqual(test, po3, "Should be equal") //FIXME, should work. Asana : https://app.asana.com/0/861870036984/13123030433568

        let allPeople = realm.objects(EmployeeObject)
        XCTAssertEqual(allPeople.count, 3, "Only links should have been deleted, not the employees")
    }

    func testIndexOfObject_objc() {
        let realm = realmWithTestPath()

        realm.beginWrite()
        let po1 = makeEmployee(realm, 40, "Joe", true)
        let po2 = makeEmployee(realm, 30, "John", false)
        let po3 = makeEmployee(realm, 25, "Jill", true)
        realm.commitWrite()

        let results = realm.objects(EmployeeObject).filter("hired = YES")
        XCTAssertEqual(2, results.count)
        XCTAssertEqual(0, results.indexOf(po1)!);
        XCTAssertEqual(1, results.indexOf(po3)!);
        XCTAssertNil(results.indexOf(po2));
    }

    func testIndexOfObjectWhere_objc() {
        let realm = realmWithTestPath()

        realm.beginWrite()
        makeEmployee(realm, 40, "Joe", true)
        makeEmployee(realm, 30, "John", false)
        makeEmployee(realm, 25, "Jill", true)
        realm.commitWrite()

        let results = realm.objects(EmployeeObject).filter("hired = YES")
        XCTAssertEqual(2, results.count)
        XCTAssertEqual(0, results.indexOf("age = %d", 40)!)
        XCTAssertEqual(1, results.indexOf("age = %d", 25)!)
        XCTAssertNil(results.indexOf("age = %d", 30))
    }

    func testSortingExistingQuery_objc() {
        let realm = realmWithTestPath()

        realm.beginWrite()
        makeEmployee(realm, 20, "A", true)
        makeEmployee(realm, 30, "B", false)
        makeEmployee(realm, 40, "C", true)
        realm.commitWrite()

        let sortedByAge = realm.objects(EmployeeObject).sorted("age", ascending: true)
        let sortedByName = sortedByAge.sorted("name", ascending: false)

        XCTAssertEqual(20, sortedByAge[0]!.age)
        XCTAssertEqual(40, sortedByName[0]!.age)
    }
}
