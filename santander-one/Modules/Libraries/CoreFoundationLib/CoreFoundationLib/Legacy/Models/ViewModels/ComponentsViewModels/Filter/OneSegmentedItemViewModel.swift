//
//  OneSegmentedItemViewModel.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 24/9/21.
//

import Foundation

public struct OneSegmentedItemViewModel {
    public let imageKey: String
    public let descriptionKey: String
    public var index: Int
    
    public init(imageKey: String, descriptionKey: String, index: Int) {
        self.imageKey = imageKey
        self.descriptionKey = descriptionKey
        self.index = index
    }
}
