//
//  OneRadioButtonsContainerViewModel.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 18/10/21.
//

import Foundation

public final class OneRadioButtonsContainerViewModel {
    public let selectedIndex: Int
    public let viewModels: [OneRadioButtonViewModel]
    
    public init(selectedIndex: Int, viewModels: [OneRadioButtonViewModel]) {
        self.selectedIndex = selectedIndex
        self.viewModels = viewModels
    }
}
