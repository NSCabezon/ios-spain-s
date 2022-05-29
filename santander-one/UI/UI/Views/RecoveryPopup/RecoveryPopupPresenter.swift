//
//  RecoveryPopupPresenter.swift
//  UI
//
//  Created by alvola on 20/10/2020.
//

import CoreFoundationLib

public protocol RecoveryPopupPresenterProtocol {
    var view: RecoveryPopupProtocol? { get set }
    var delegate: RecoveryPopupPresenterDelegate? { get set }
    func shouldShow(_ shouldShow: @escaping (Bool) -> Void)
    func didSelectManageDebt()
    func viewDidLoad()
}

public protocol RecoveryPopupPresenterDelegate: AnyObject {
    func didSelectOffer(offer: OfferEntity)
}

public final class RecoveryPopupPresenter: RecoveryPopupPresenterProtocol {
    
    private let dependenciesResolver: DependenciesResolver
    private var recovery: RecoveryEntity?
    private var candidateOffer: (location: PullOfferLocation, offer: OfferEntity)?
    
    private var getRecoveryLevelUseCase: GetRecoveryLevelUseCase {
        return self.dependenciesResolver.resolve()
    }
    
    private var getPullOffersUseCase: GetPullOffersUseCase {
        return self.dependenciesResolver.resolve()
    }
    
    private var offerKey = GlobalPositionPullOffers.recoveryN3
    private struct Constants {
        static var locations = PullOffersLocationsFactoryEntity().pendingRequestRecovery
    }
    public weak var view: RecoveryPopupProtocol?
    public weak var delegate: RecoveryPopupPresenterDelegate?
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func viewDidLoad() {
        trackScreen()
        processRecovery()
    }
  
    private func processRecovery() {
        guard let recovery = self.recovery else { return }
        let amount = Decimal(-recovery.amount).decorateAmount("€")
        let debtCount = recovery.debtCount
        let title = debtCount > 1 ?
                    localized("recoveredMoney_label_productPendingPays", [StringPlaceholder(.value, String(debtCount))]) :
            LocalizedStylableText(text: recovery.debtTitle, styles: nil)
        
        let viewModel = RecoveryViewModel(debtCount: recovery.debtCount,
                                          debtTitle: title.text,
                                          amount: amount,
                                          offer: recovery.offer,
                                          location: recovery.location)
        
        view?.setRecoveryViewModel(viewModel)
    }
    
    public func shouldShow(_ shouldShow: @escaping (Bool) -> Void) {
        self.loadOffer { [weak self] in
            self?.loadRecovery({
                guard self?.recovery != nil else { return shouldShow(false) }
                shouldShow(self?.needToShowRecovery() ?? false)
            })
        }
    }
    
    public func didSelectManageDebt() {
        trackEvent(.manageDebt, parameters: [:])
        guard let offer = recovery?.offer else { return }
        self.delegate?.didSelectOffer(offer: offer)
    }
    
    func needToShowRecovery() -> Bool {
        guard let recovery = recovery, recovery.level == 3 else { return false }
        return true
    }
    
    func loadOffer(_ completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: self.getPullOffersUseCase.setRequestValues(requestValues: GetPullOffersUseCaseInput(locations: Constants.locations)),
            useCaseHandler: self.dependenciesResolver.resolve(),
            onSuccess: { [weak self] offers in
                guard let offerKey = self?.offerKey,
                    let location = offers.pullOfferCandidates.location(key: offerKey) else { return completion() }
                self?.candidateOffer = (location.location, location.offer)
                completion()
            },
            onError: { _ in
                completion()
        })
    }
    
    func loadRecovery(_ completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: self.getRecoveryLevelUseCase,
            useCaseHandler: self.dependenciesResolver.resolve(),
            onSuccess: { [weak self] result in
                self?.recovery = RecoveryEntity(debtCount: result.debtCount,
                                                   debtTitle: result.debtTitle,
                                                   amount: result.amount,
                                                   offer: self?.candidateOffer?.offer,
                                                   location: self?.candidateOffer?.location,
                                                   level: result.level)
                completion()
            },
            onError: { _ in
                completion()
        })
    }
}

extension RecoveryPopupPresenter: AutomaticScreenActionTrackable {
    public var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    public var trackerPage: RecoveryPopupPage {
        return RecoveryPopupPage()
    }
}
