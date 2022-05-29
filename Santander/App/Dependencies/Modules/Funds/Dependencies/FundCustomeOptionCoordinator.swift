//
//  FundCustomeOptionCoordinator.swift
//  Santander
//
//  Created by Ernesto Fernandez Calles on 24/3/22.
//

import UI
import Funds
import CoreFoundationLib
import Foundation
import CoreDomain
import RetailLegacy

private enum FundCustomeOptionConstant {
    static let operateOption = "operate"
    static let browserOption = "browser"
}

final class FundCustomeOptionCoordinator: BindableCoordinator {
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    var dataBinding: DataBinding = DataBindingObject()
    var pullOffers: [PullOfferLocation : OfferEntity] = [:]
    let dependenciesResolver: DependenciesResolver

    private var offerCoordinatorLauncher: OfferCoordinatorLauncher {
        self.dependenciesResolver.resolve(for: OfferCoordinatorLauncher.self)
    }

    init(dependencyResolver: DependenciesResolver) {
        self.dependenciesResolver = dependencyResolver
        self.getLocations()
    }

    func start() {
        guard let option: FundOptionRepresentable = self.dataBinding.get() else { return }
        var selectedOffer: OfferEntity?
        switch option.type {
        case .custom(identifier: FundCustomeOptionConstant.operateOption):
            selectedOffer = self.pullOffers[PullOfferLocation.FONDO_SUSCRIPCION]
        case .custom(identifier: FundCustomeOptionConstant.browserOption):
            selectedOffer = self.pullOffers[PullOfferLocation.CONTRATAR_FONDOS]
        default:
            break
        }
        guard let selectedOffer = selectedOffer else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
            return
        }
        self.offerCoordinatorLauncher.executeOffer(selectedOffer)
    }
}

private extension FundCustomeOptionCoordinator {
    func getLocations() {
        let globalPosition: GlobalPositionRepresentable = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        let fundsLocations: [PullOfferLocation] = [PullOfferLocation.FONDO_SUSCRIPCION, PullOfferLocation.CONTRATAR_FONDOS]
        guard let userId: String = globalPosition.userId else { return }
        fundsLocations.forEach { location in
            if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                self.pullOffers[location] = OfferEntity(candidate, location: location)
            }
        }
    }
}
