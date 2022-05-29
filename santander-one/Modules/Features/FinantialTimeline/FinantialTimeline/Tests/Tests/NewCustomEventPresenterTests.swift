//
//  NewCustomEventPresenterTests.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by Jose Ignacio de Juan Díaz on 11/09/2019.
//

import XCTest
import SantanderUIKitLib
@testable import FinantialTimeline

class NewCustomEventPresenterTests: XCTestCase {
    
    // MARK: -
    var presenter: NewCustomEventPresenter!
    var view: NewCustomEventViewProtocol!
    var router: NewCustomEventRouterMock!
    
    var expect: XCTestExpectation!

    override func setUp() {
        super.setUp()
        expect = XCTestExpectation(description: "testCreateCustomEventTapped")
        TestHelpers.mockResponse(forPath: "/timeline/configuration", withFile: "configuration.json")
        view = NewCustomEventViewMock()
        guard let mockView = view  else { return }
        let interactor = NewCustomEventInteractorMock()
        router = NewCustomEventRouterMock()
        presenter = NewCustomEventPresenter(view: mockView, router: router, interactor: interactor, periodicEventToEdit: nil)
    }

    override func tearDown() {
        presenter = nil
        view = nil
        super.tearDown()
    }
    
    func testCreateCustomEventTapped() {
        
        // G
        let title = "Title"
        let description = "Description"
        let startDate = "10-10-2019"
        let endDate = "10-11-2019"
        let frequency: SantanderDropDownData<Frequency> = SantanderDropDownData(label: "Annually", value: .annually)

        let mockNewEvent = NewCustomEventViewControllerOutput(title: title,
                                                              description: description,
                                                              startDate: startDate,
                                                              endDate:endDate,
                                                              frequency: frequency)

        router.expectation = expect

        // W
        presenter.createCustomEventTapped(mockNewEvent)

        // T
        wait(for: [expect], timeout: 2)
    
    }
    
    func testBuildNewEvent() {
        
        // G
        let title = "Title"
        let description = "Description"
        let startDate = "10-10-2019"
        let endDate = "10-11-2019"
        let frequency: SantanderDropDownData<Frequency> = SantanderDropDownData(label: "Annually", value: .annually)
        
        let startDateExpected = "20191010\(Utils.getTimeZone())"
        let endDateExpected = "20191110\(Utils.getTimeZone())"
        let frequencyExpected = Frequency.annually
        
        let mockNewEvent = NewCustomEventViewControllerOutput(title: title,
                                                              description: description,
                                                              startDate: startDate,
                                                              endDate:endDate,
                                                              frequency: frequency)
        
        // W
        let newEvent = presenter.buildNewEvent(mockNewEvent)
        
        // T
        XCTAssertEqual(newEvent?.title, title)
        XCTAssertEqual(newEvent?.description, description)
        XCTAssertEqual(newEvent?.startDate, startDateExpected)
        XCTAssertEqual(newEvent?.endDate, endDateExpected)
        XCTAssertEqual(newEvent?.frequency, frequencyExpected)
    }
    
    func testSetFrequencyIsOK() {
        
        // G
        let title = "Title"
        let description = "Description"
        let startDate = "10-10-2019"
        let endDate = "10-11-2019"
        let frequency: SantanderDropDownData<Frequency> = SantanderDropDownData(label: "Annually", value: .annually)
        
        var mockNewEvent = NewCustomEventViewControllerOutput(title: title,
                                                              description: description,
                                                              startDate: startDate,
                                                              endDate:endDate,
                                                              frequency: frequency)
        
        // W
        presenter.setFrequencyIsOK(mockNewEvent)
        // T
        XCTAssertEqual(presenter.frequencyIsOK, false)
        
        // G
        mockNewEvent.endDate = "10-11-2020"
        // W
        presenter.setFrequencyIsOK(mockNewEvent)
        // T
        XCTAssertEqual(presenter.frequencyIsOK, true)
    }
    
    func testRequirementsAreOK() {
        
        // All set ok
        // G
        let title = "Title"
        let description = "Description"
        let startDate = "10-10-2019"
        let endDate = "10-11-2020"
        let frequency: SantanderDropDownData<Frequency> = SantanderDropDownData(label: "Annually", value: .annually)
        
        presenter.frequencyIsOK = true
        
        var mockNewEvent = NewCustomEventViewControllerOutput(title: title,
                                                              description: description,
                                                              startDate: startDate,
                                                              endDate:endDate,
                                                              frequency: frequency)
        
        // W
        var result = presenter.requerimentsAreOK(mockNewEvent)
        // T
        XCTAssertEqual(result, true)
        
        // Title not set
        // G
        mockNewEvent.title = ""
        // W
        result = presenter.requerimentsAreOK(mockNewEvent)
        // T
        XCTAssertEqual(result, false)
        
        // Start date not set
        // G
        mockNewEvent.title = "Title"
        mockNewEvent.startDate = nil
        // W
        result = presenter.requerimentsAreOK(mockNewEvent)
        // T
        XCTAssertEqual(result, false)
        
        // frequencyIsOK is false
        // G
        mockNewEvent.startDate = "10-10-2019"
        presenter.frequencyIsOK = false
        // W
        result = presenter.requerimentsAreOK(mockNewEvent)
        // T
        XCTAssertEqual(result, false)

    }

    

}
