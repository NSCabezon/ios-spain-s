//
//  AtmFilterAdapter.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 11/3/20.
//

import Foundation

struct AtmServiceFilterAdapter: Sequence, IteratorProtocol {
    private let viewModel: AtmViewModel
    private var serviceFilters = [AtmFilterView.AtmFilter]()
    private var currentIndex = 0
    
    init(viewModel: AtmViewModel) {
        self.viewModel = viewModel
        self.addServiceFilters()
    }
    
    mutating func next() -> AtmFilterView.AtmFilter? {
        guard self.currentIndex < serviceFilters.count else { return nil }
        let nextIndex = currentIndex
        self.currentIndex += 1
        return self.serviceFilters[nextIndex]
    }
    
    private mutating func addServiceFilters() {
        self.addDeposit()
        self.addContactLess()
        self.addBardCode()
    }
    
    private mutating func addDeposit() {
        guard self.viewModel.hasDeposit == true else { return }
        self.serviceFilters.append(.depositCash)
    }
    
    private mutating func addContactLess() {
        guard self.viewModel.hasContactLess == true else { return }
        self.serviceFilters.append(.contactless)
    }
    
    private mutating func addBardCode() {
        guard self.viewModel.hasBarsCode == true else { return }
        self.serviceFilters.append(.barcode)
    }
}
