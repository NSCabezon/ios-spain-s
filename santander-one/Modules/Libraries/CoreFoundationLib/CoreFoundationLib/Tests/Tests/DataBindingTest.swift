//
//  DataBindingTest.swift
//  CoreFoundationLib-Unit-Tests
//
//  Created by Ernesto Fernandez Calles on 20/5/22.
//

import XCTest
import CoreFoundationLib
import CoreDomain
import OpenCombine

class DataBindingTest: XCTestCase {

    func testSaveDataBinding() throws {
        let dataBinding: DataBinding = DataBindingObject()

        let stu: String = "NotOptional"
        dataBinding.set(stu)

        let saved: String? = dataBinding.get()
        XCTAssertTrue(stu == saved)
    }

    func testSaveDataBindingOptional() throws {
        let dataBinding: DataBinding = DataBindingObject()
        let stu: String? = "Optional"
        dataBinding.set(stu)

        let saved: String? = dataBinding.get()
        XCTAssertTrue(stu == saved)
    }

    func testSaveDataBindingNil() throws {
        let dataBinding: DataBinding = DataBindingObject()

        let stu: String? = nil
        dataBinding.set(stu)

        let saved: String? = dataBinding.get()
        XCTAssertNil(saved)
    }

    func testSaveDataBindingNilAndValue() throws {
        let dataBinding: DataBinding = DataBindingObject()

        let stu: String? = nil
        let stuValue: Int? = 100
        dataBinding.set(stu)
        dataBinding.set(stuValue)

        let saved: Int? = dataBinding.get()
        XCTAssertNotNil(saved)
    }

    func testSaveDataBindingNilAndValues() throws {
        let dataBinding: DataBinding = DataBindingObject()

        let stuString: String? = "String"
        let stu: String? = nil
        let stuValue: Int? = 100
        dataBinding.set(stuString)
        dataBinding.set(stu)
        dataBinding.set(stuValue)

        let saved: Int? = dataBinding.get()
        XCTAssertNotNil(saved)
    }
}
