//
//  MockCardTransactionDetailCoordinator.swift
//  Pods
//
//  Created by Hernán Villamil on 23/4/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib
import UI
@testable import Cards

class MoMockCardTransactionDetailCoordinator: CardTransactionDetailCoordinator {
    var onFinish: (() -> Void)?
    var dataBinding: DataBinding
    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController?
    
    var openMenuCalled: Bool = false
    var cardActionCalled: Bool = false
    var easyPayCalled: Bool = false
    var mapViewCalled: Bool = false
    var offerCalled: Bool = false
    var startCalled: Bool = false
    
    init() {
        dataBinding = DataBindingObject()
        childCoordinators = []
    }
    
    func openMenu() {
        openMenuCalled = true
    }
    
    func goToCardAction(_ card: CardRepresentable, type: CardActionType) {
        cardActionCalled = true
    }
    
    func goToEasyPay(card: CardRepresentable, transaction: CardTransactionRepresentable, easyPayOperativeDataEntity: EasyPayOperativeDataEntity?) {
        easyPayCalled = true
    }
    
    func goToMapView(card: CardRepresentable, type: CardMapTypeConfiguration) {
        mapViewCalled = true
    }
    
    func goToOffer(offer: OfferRepresentable) {
        offerCalled = true
    }

    
    func start() {
        startCalled = true
    }
    

}
