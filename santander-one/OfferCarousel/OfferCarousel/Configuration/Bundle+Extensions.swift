//
//  Bundle+Extensions.swift
//  OfferCarousel
//
//  Created by Rubén Márquez Fernández on 26/7/21.
//

import Foundation

extension Bundle {
    static let module: Bundle? = {
        let podBundle = Bundle(for: OfferCarouselBuilder.self)
        let bundleURL = podBundle.url(forResource: "OfferCarousel", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
