//
//  UIBindingTest.swift
//  OpenKitTests
//
//  Created by Juan Carlos López Robles on 3/21/22.
//

import XCTest
import OpenCombine
import OpenCombineDispatch
import UI

class UIBindingTest: XCTestCase {
    var subscriptions = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        super.tearDown()
        subscriptions.removeAll()
    }
    func test_Given_expected_result_When_collectingValueEnds_Then_bindResult_intoViewValue() throws {
        let view = MyView()
        let expected = [1, 2, 3, 4]
        expected.publisher
            .collect()
            .bind(to: view.bindable.value)
            .store(in: &subscriptions)
        XCTAssertEqual(expected, view.value)
    }
   
    func test_Given_AsyncPublisher_When_publishedValueOutsideMainThread_Then_bindTheResultOnMainThread() throws {
        let view = MyView()
        let exp =  expectation(description: "BindView Text")
        view.exp = exp
        let subject = PassthroughSubject<String, Never>()
        subject
            .receive(on: DispatchQueue.OCombine(.main))
            .bind(to: view.bindable.name)
            .store(in: &subscriptions)
        
        DispatchQueue.global().async {
            subject.send("Value")
        }
        
        wait(for: [exp], timeout: 10)
        XCTAssertEqual("Value", view.name)
    }
}

fileprivate class MyView: UIView {
    var value = [Int]()
    var name = ""
    var exp: XCTestExpectation?
}

extension UIReactive where Base: MyView {
    var value: Binder<Base, [Int]> {
        return Binder(base) { view, value in
            view.value = value
        }
    }
    
    var name: Binder<Base, String> {
        return Binder(base) { view, newName in
            view.name = newName
            view.exp?.fulfill()
        }
    }
}
