//
//  OneFilterLargeWithIconViewModel.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 29/9/21.
//

import Foundation

public struct OneFilterLargeWithIconViewModel {
    public let segmentViewModels: [OneSegmentedItemViewModel]
    
    public init(_ viewModels: [OneSegmentedItemViewModel]) {
        self.segmentViewModels = viewModels
    }
    
    public var segmentTitles: [String] {
        return self.segmentViewModels.map { $0.descriptionKey }
    }
}
