//
//  OfferCarouselViewModel.swift
//  Account
//
//  Created by Rubén Márquez Fernández on 23/7/21.
//

import Foundation

public struct OfferCarouselViewModel {
    public let elems: [OfferCarouselViewModelType]

    public init(elements: [OfferCarouselViewModelType]) {
        self.elems = elements
    }
}
