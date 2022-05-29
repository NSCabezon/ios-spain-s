//
//  SearchBarTests.swift
//  LocatorAppTests
//
//  Created by Ivan Cabezon on 2/8/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import XCTest
import MapKit

@testable import BranchLocator

class SearchBarTests: XCTestCase {
	
	var mainViewController: MapViewController!
	
    override func setUp() {
        super.setUp()
		
		mainViewController = MapRouter.createModule(urlLauncher: UIApplication())
		_ = mainViewController.view
    }
	
    func testSearchBarShowsTableView() {
		mainViewController.searchTextField.becomeFirstResponder()
		
		XCTAssert(self.mainViewController.searchResultsTableView.isHidden == false)
		XCTAssertEqual(self.mainViewController.searchResultsTableView.numberOfRows(inSection: 0), 0)
	}
	
	func testInputTextLessThan3CharsInSearchBar() {
		mainViewController.searchTextField.becomeFirstResponder()
		
		mainViewController.searchTextField.text = "mad"
		
		XCTAssert(!self.mainViewController.searchResultsTableView.isHidden)
		XCTAssertEqual(self.mainViewController.searchResultsTableView.numberOfRows(inSection: 0), 0)
	}
	
	func testInputTextMoreThan3CharsInSearchBar() {
		mainViewController.searchTextField.becomeFirstResponder()
		
		let searchText = "madrid"
		
		mainViewController.searchTextField.text = searchText
		XCTAssert(!self.mainViewController.searchResultsTableView.isHidden)
//		XCTAssertGreaterThan(self.mainViewController.searchResultsTableView.numberOfRows(inSection: 0), 0)
	}
	
	func testInputTextMoreThan3CharsAndGoToFirstResultInSearchBar() {
		mainViewController.searchTextField.becomeFirstResponder()
		
		mainViewController.searchTextField.text = "madrid"
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
			XCTAssert(!self.mainViewController.searchResultsTableView.isHidden)
			XCTAssert(self.mainViewController.searchTextField.isFirstResponder)
			XCTAssertGreaterThan(self.mainViewController.searchResultsTableView.numberOfRows(inSection: 0), 0)
		}
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
}
