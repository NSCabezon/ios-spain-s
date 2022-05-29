//
//  DetailPresenterTests.swift
//  BranchLocatorTests
//
//  Created by vectoradmin on 26/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import XCTest

@testable import BranchLocator

class DetailPresenterTests: XCTestCase {
    
    var presenter: POIDetailPresenter!
    let mockView = DetailViewControllerMock()
    let mockInteractor = DetailInteractorMock()
    let mockRouter = DetailRouterMock()
    
    override func setUp() {
        super.setUp()
        
        presenter = POIDetailPresenter(interface: mockView, interactor: mockInteractor, router: mockRouter)
    }
    
    func testInitWorks() {
        XCTAssertNotNil(presenter.interactor)
        XCTAssertNotNil(presenter.view)
        XCTAssertNotNil(presenter.router)
    }
	
	func testViewDidLoadOK() {
		mockInteractor.poi = POIAnnotation(mapPin: POI(JSONString: kOnlyOnePOI)!)
		presenter.viewDidLoad()
		XCTAssertTrue(mockView.didCallConfigureWithMapPin)
	}
	
	func testViewDidLoadKO() {
		presenter.viewDidLoad()
		XCTAssertFalse(mockView.didCallConfigureWithMapPin)
	}

	func testSetSelectedPOI() {
		let p = POI(JSONString: kOnlyOnePOI)
		let poi = POIAnnotation(mapPin: p!)
		
		presenter.setSelectedPOI(poi)
		XCTAssert(poi == mockInteractor.poi)
	}
	
	func testScheduleNotNil() {
		let p = POI(JSONString: kOnlyOnePOI)
		let sche = presenter.getSchedule(from: p!)
		XCTAssertNotNil(sche)
	}
	
	func testDeselectPin() {
		mockInteractor.poi = POIAnnotation(mapPin: POI(JSONString: kOnlyOnePOI)!)
		presenter.detailDelegate = mockView
		presenter.deselectPin()
		XCTAssertTrue(mockView.didCallDeselectPin)
	}
	
	func testHandleOpenClose() {
		presenter.detailDelegate = mockView
		presenter.handleOpenOrClose()
		XCTAssertTrue(mockView.didCallHandleOpenOrClose)
	}

	
	func testMakeCallMainPOI() {
		presenter.makeCall()
		XCTAssertTrue(mockRouter.didCallCanOpenURL)
		XCTAssertTrue(mockRouter.didCallOpenURL)
	}
	
	func testMakeCallSecondayPOI() {
		presenter.mainPOISelected = false
		presenter.makeCall()
		XCTAssertTrue(mockRouter.didCallCanOpenURL)
		XCTAssertTrue(mockRouter.didCallOpenURL)
	}
	
	func testMakeAppointment() {
		presenter.makeAppintment()
		XCTAssertTrue(mockRouter.didCallCanOpenURL)
		XCTAssertTrue(mockRouter.didCallOpenURL)
	}
	
	func testRouteToPOIAction() {
		mockInteractor.poi = POIAnnotation(mapPin: POI(JSONString: kOnlyOnePOI)!)
		presenter.routeToPOIAction()
		XCTAssertTrue(mockRouter.didCallNavigateToDestination)
	}
	
//	func testAttributedStringForMain() {
//		let poi = POI(JSONString: kOnlyOnePOI)
//		let str = presenter.getAttributtedStringFor(mainPoi: poi!)
//		XCTAssertNotNil(str)
//	}
//
//	func testAttributedStringForSecundary() {
//		let poi = POI(JSONString: kOnlyOnePOI)
//		let str = presenter.getAttributtedStringFor(secondaryPoiIn: poi!)
//		XCTAssertNotNil(str)
//	}
}
