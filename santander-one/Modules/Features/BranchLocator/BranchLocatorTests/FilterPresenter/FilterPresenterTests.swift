//
//  FilterPresenterTests.swift
//  BranchLocatorTests
//
//  Created by Ivan Cabezon on 13/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import XCTest

@testable import BranchLocator

class FilterPresenterTests: XCTestCase {
	
	var presenter: FiltersPresenter!
	let mockView = FiltersViewControllerMock()
	let mockInteractor = FilterInteractorMock()
	let mockRouter = FilterRouterMock()
    
    override func setUp() {
        super.setUp()
		presenter = FiltersPresenter(interface: mockView, filterDelegate: mockView, interactor: mockInteractor, router: mockRouter)
    }
	
	func testInitWorks() {
		XCTAssertNotNil(presenter.filterDelegate)
		XCTAssertNotNil(presenter.interactor)
		XCTAssertNotNil(presenter.view)
		XCTAssertNotNil(presenter.router)
	}

	func testShowMoreLess() {
		presenter.showAllFilters = false
		presenter.showMoreLess()
		XCTAssert(presenter.showAllFilters)
		XCTAssert(mockInteractor.didCallSaveSelection)
		XCTAssert(mockView.didCallReloadData)
	}
	
	func testViewDidLoad() {
        presenter.availableFilters = defaultAvailableFilters()
		presenter.viewDidLoad()
		XCTAssertEqual(mockView.callsToSelectedRow, mockInteractor.selectedFilters.count)
	}
	
	func testGetSelectedItemsOk() {
		mockView.indexPathsForSelectedRowsReturnEmpty = false
        presenter.availableFilters = defaultAvailableFilters()
        
		let filters = presenter.getSelectedItemsAtTableView()
		let returningFilters = [FilterType.mostPopular.filters[0], FilterType.mostPopular.filters[1]]
		XCTAssertEqual(filters, returningFilters)
	}
	
	func testGetSelectedItemsKo() {
		let filters = presenter.getSelectedItemsAtTableView()
		XCTAssertEqual(filters.count, 0)
	}
	
	func testApplyFilters() {
		presenter.applyFilters()
		XCTAssertTrue(mockInteractor.didCallSaveSelection)
		XCTAssertTrue(mockView.didCallBackAndApply)
	}
	/*
	func testCleanFiltersWhenHasCleanned() {
		presenter.hasCleaned = true
		presenter.clearFilters()
		XCTAssertFalse(mockView.didCallDeselectRow)
		XCTAssertTrue(mockView.didCallSetClearButtonTitle)
		XCTAssertFalse(presenter.hasCleaned)
	}
	
	func testCleanFiltersWhenDoesntHaveCleanned() {
		presenter.clearFilters()
		XCTAssertTrue(mockView.didCallSetClearButtonTitle)
		XCTAssertTrue(presenter.hasCleaned)
		XCTAssertTrue(mockView.didCallDeselectRow)
	}
	*/
	func testCanOpenURL() {
		_ = presenter.canOpenURL(url: URL(string: "www.google.com")!)
		XCTAssertTrue(mockRouter.didCallCanOpenURL)
	}
	
	func testOpenURL() {
		_ = presenter.openURL(url: URL(string: "www.google.com")!)
		XCTAssertTrue(mockRouter.didCallOpenURL)
	}
	
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
