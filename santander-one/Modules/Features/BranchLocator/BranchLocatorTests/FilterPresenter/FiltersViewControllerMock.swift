//
//  FilterViewControllerMock.swift
//  BranchLocatorTests
//
//  Created by Ivan Cabezon on 13/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import Foundation

@testable import BranchLocator

class FiltersViewControllerMock: FiltersViewProtocol {
	
	var presenter: FiltersPresenterProtocol?
	
	var indexPathsForSelectedRowsReturnEmpty = true
	
	var didCallReloadData = false
	var didCallBackAndApply = false
	var didCallSetClearButtonTitle = false
	var didCallDeselectRow = false
	
	var callsToSelectedRow = 0
	
	func backAndApplyFilters() {
		didCallBackAndApply = true
	}
	
	func changeApplyButton(enabled: Bool) {
		
	}
	
	func setClearButtonTitle(title: String) {
		didCallSetClearButtonTitle = true
	}
	
    func selectRow(at indexPath: IndexPath, animated: Bool, scrollPosition: UITableView.ScrollPosition) {
		callsToSelectedRow += 1
	}
	
	func indexPathsForSelectedRows() -> [IndexPath]? {
		if indexPathsForSelectedRowsReturnEmpty {
			return []
		} else {
			return [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)]
		}
	}
	
	func deselectRow(at indexPath: IndexPath, animated: Bool) {
		didCallDeselectRow = true
	}
	
	func dequeueReusableCell(with identifier: String, for indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
	}
	
	func reloadTableView() {
		didCallReloadData = true
	}
	
	func scrolToSection(showAllFilters: Bool) {
		
	}
}

extension FiltersViewControllerMock: FilterDelegate {
	func apply(_ filters: [Filter]) {
		
	}
}
