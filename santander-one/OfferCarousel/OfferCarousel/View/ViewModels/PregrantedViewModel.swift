//
//  PregrantedViewModel.swift
//  OfferCarousel
//
//  Created by Rubén Márquez Fernández on 23/7/21.
//

import CoreFoundationLib

public struct PregrantedViewModel {
    public let offerLocation: PullOfferLocation
    public let offerEntity: OfferEntity
    private let entity: LoanBannerLimitsEntity
    var isPregrantedProcessInProgress: Bool {
        return entity.simulationAlreadyInProgress
    }
    var amountMaximum: Float {
        guard let value = entity.amountEntity?.value,
              let double = Double(value.description) else { return 0.0 }
        return Float(double) 
    }
    
    public init(entity: LoanBannerLimitsEntity, offerLocation: PullOfferLocation, offerEntity: OfferEntity) {
        self.entity = entity
        self.offerLocation = offerLocation
        self.offerEntity = offerEntity
    }
}
