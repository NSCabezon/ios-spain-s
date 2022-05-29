//
//  MoreTransferOptionPresenter.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/26/19.
//
import CoreFoundationLib

protocol NewShipmentPresenterProtocol {
    var view: NewShipmentViewProtocol? {get set}
    func viewDidLoad()
    func viewDidAppear()
    func didSelectClose()
}

final class NewShipmentPresenter {
    var view: NewShipmentViewProtocol?
    var dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    var moduleCoordinator: TransferHomeModuleCoordinatorDelegate {
        return dependenciesResolver.resolve(for: TransferHomeModuleCoordinatorDelegate.self)
    }
    
    var coordinator: NewShipmentCoordinator {
        return dependenciesResolver.resolve(for: NewShipmentCoordinator.self)
    }
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var pullOfferUseCase: GetPullOffersUseCase {
        return dependenciesResolver.resolve(for: GetPullOffersUseCase.self)
    }
    
    var configuration: TransfersHomeConfiguration {
        return dependenciesResolver.resolve(for: TransfersHomeConfiguration.self)
    }
    
    private var accountHomeModifier: TransferHomeModifier {
        self.dependenciesResolver.resolve(for: TransferHomeModifier.self)
    }
    
    var locations: [PullOfferLocation] {
        return [PullOfferLocation(stringTag: TransferPullOffers.fxpayTransferHomeOffer,
                                  hasBanner: false, pageForMetrics: trackerPage.page)]
    }
    
    private var setTransferHomeUseCase: SetTransferHomeUseCaseProtocol {
        return self.dependenciesResolver.resolve(firstTypeOf: SetTransferHomeUseCaseProtocol.self)
    }
    
    var selectedAccount: AccountEntity?
    var offers: [PullOfferLocation: OfferEntity] = [:]
    private var isTransferBetweenAccountsAvailable: Bool?
}

extension NewShipmentPresenter: NewShipmentPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
    }
    
    func viewDidAppear() {
        self.setTransferHome()
    }
    
    private func loadPullOffers(_ completion: @escaping() -> Void) {
        UseCaseWrapper(
            with: self.pullOfferUseCase.setRequestValues(requestValues: GetPullOffersUseCaseInput(locations: locations)),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                self?.offers = result.pullOfferCandidates
                completion()
            }, onError: {_ in
                completion()
        }
        )
    }
    
    func didSelectClose() {
        self.coordinator.dismiss()
    }
}

extension NewShipmentPresenter: AutomaticScreenActionTrackable {
    var trackerPage: GPSendMoneyPage {
        return GPSendMoneyPage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

private extension NewShipmentPresenter {
    func setTransferHome() {
        Scenario(useCase: setTransferHomeUseCase)
            .execute(on: useCaseHandler)
            .onSuccess { [weak self] result in
                self?.isTransferBetweenAccountsAvailable = result.isTransferBetweenAccountsAvailable
                self?.loadPullOffers { [weak self] in
                    guard let transferActions = self?.getNewShipmentTransferActions() else { return }
                    self?.view?.showTransferActions(transferActions)
                }
            }
    }
    
    func getNewShipmentTransferActions() -> [TransferActionViewModel] {
        let transferBetweenAccounts = self.isTransferBetweenAccountsAvailable ?? false
        let homeActions: [TransferActionViewModel] = self.accountHomeModifier.getNewShipmentTransferActions(transferBetweenAccounts).map {
            let value = $0.values()
            return TransferActionViewModel(
                title: value.title,
                description: value.description,
                imageName: value.imageName,
                actionType: self.addTranferActionWithOffer(actionType: $0),
                action: self.didSelectActionType)
        }
        return homeActions
    }
    
    func didSelectActionType(_ actionType: TransferActionType) {
        self.trackTransferAction(actionType)
        self.accountHomeModifier.didSelectTransferAction(type: actionType,
                                                         account: configuration.selectedAccount)
    }
    
    func addTranferActionWithOffer(actionType: TransferActionType) -> TransferActionType {
        switch actionType {
        case .onePayFX:
            let fxpayOffer = self.offers.location(key: TransferPullOffers.fxpayTransferHomeOffer)?.offer
            return .onePayFX(fxpayOffer)
        default: return actionType
        }
    }
    
    func trackTransferAction(_ type: TransferActionType) {
        switch type {
        case .transfer:
            self.trackEvent(.transfer, parameters: [:])
        case .transferBetweenAccounts:
            self.trackEvent(.internalTransfer, parameters: [:])
        case .atm:
            self.trackEvent(.codeWithdraw, parameters: [:])
        default: break
        }
    }
}
