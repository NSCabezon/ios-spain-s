//
//  MapFiltersTests.swift
//  LocatorAppTests
//
//  Created by Ivan Cabezon on 31/8/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import XCTest

@testable import BranchLocator

class MapFiltersTests: XCTestCase {
	
	var mainViewController: MapViewController!
    
    var interactor = FiltersInteractor()
	
    override func setUp() {
        super.setUp()
		
		mainViewController = MapRouter.createModule(urlLauncher: UIApplication())
		_ = mainViewController.view
    }
    
    func testSaveReadAndDeleteFilters() {
        let filters:[Filter] = [Filter(rawValue: "wifi")!, Filter(rawValue: "parking")!, Filter(rawValue: "available")!]
        let userDefault = UserDefaults.standard
        
        interactor.save(with: filters)
        let setedFilter = interactor.selectedFilters
        XCTAssert(setedFilter.count == 3)

        interactor.deleteAllFilters()
        XCTAssert(userDefault.stringArray(forKey: "currentFilter") == nil)
        
        let emptyFilter = interactor.selectedFilters
        XCTAssert(emptyFilter == FilterType.defaultFilters)
		
		let a = degreesToRadians(5.9)
		print(a)
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        super.tearDown()
    }
	
	func testFiltersOnOpening() {
		// TODO: if no filters saved check if default filters are ok and if something is saved check  that shows in UI correctly
	}
	
}
