//
//  NearAtmViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 16/11/2020.
//

import Foundation

struct NearAtmViewModel {
    let atmViewModels: [AtmViewModel]?
    private let isEnrichedAtmServiceEnabled: Bool
    
    init(atmViewModels: [AtmViewModel]?, isEnrichedAtmServiceEnabled: Bool) {
        self.atmViewModels = atmViewModels
        self.isEnrichedAtmServiceEnabled = isEnrichedAtmServiceEnabled
    }
    
    var isFilterHidden: Bool {
        return self.isEnrichedAtmServiceEnabled ? false : true
    }
}
