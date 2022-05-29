//
//  OneSeeAllCardViewModel.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 15/9/21.
//

import Foundation

public struct OneSeeAllCardViewModel {
    public let imageKey: String
    public let descriptionKey: String
    
    public init(imageKey: String, descriptionKey: String) {
        self.imageKey = imageKey
        self.descriptionKey = descriptionKey
    }
}
