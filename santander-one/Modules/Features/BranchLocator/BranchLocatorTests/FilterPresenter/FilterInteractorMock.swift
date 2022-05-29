//
//  FilterInteractorMock.swift
//  BranchLocatorTests
//
//  Created by Ivan Cabezon on 13/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import Foundation

@testable import BranchLocator

class FilterInteractorMock: FiltersInteractor {
	var didCallSaveSelection = false
	
	override var selectedFilters: [Filter] {
		return [Filter.opensSaturdays,
				Filter.withdrawMoney,
				
				Filter.lowDenominationBill,
				Filter.individual,
				Filter.santanderATM]
	}
	
	override func save(with filters: [Filter]) {
		didCallSaveSelection = true
	}
}
