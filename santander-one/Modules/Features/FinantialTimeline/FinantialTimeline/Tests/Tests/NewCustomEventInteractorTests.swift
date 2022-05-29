//
//  NewCustomEventInteractorTests.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by Jose Ignacio de Juan Díaz on 16/09/2019.
//

import XCTest
@testable import FinantialTimeline

class NewCustomEventInteractorTests: XCTestCase {
    
    var interactor: NewCustomEventInteractor!

    override func setUp() {
        interactor = NewCustomEventInteractor(timeLineRepository: TimeLineRepositoryMock())
        
    }

    override func tearDown() {
        interactor = nil
    }

    func testCreateNewCustomEvent() {
        // G
        let title = "MyEvent"
        let customEvent = CreateCustomEvent(id: "12345", title: title, description: "MyDescription", startDate: "20191012", endDate: "20191223", frequency: .monthly)
        
        // W
        interactor.createNewCustomEvent(customEvent) { result in
            switch result {
            case .failure(_):
                // T
                XCTFail()
            case .success(let personalEvent):
                // T
                XCTAssertEqual(personalEvent.periodicEvent?.title, title)
            }
        }
    }
}
