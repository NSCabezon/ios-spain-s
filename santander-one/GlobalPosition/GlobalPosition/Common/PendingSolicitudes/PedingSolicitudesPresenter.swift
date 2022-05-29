//
//  PendingSolicitudesPresenter.swift
//  GlobalPosition
//
//  Created by José Carlos Estela Anguita on 31/03/2020.
//

import Foundation
import CoreFoundationLib

protocol PendingSolicitudesPresenterProtocol: AnyObject {
    var view: PendingSolicitudesViewProtocol? { get set }
    func viewDidLoad()
    func shouldShow(_ shouldShow: @escaping (Bool) -> Void)
    func pendingSolicitudeClosed(_ viewModel: PendingSolicitudeViewModel)
    func pendingSolicitudeSelected(_ viewModel: PendingSolicitudeViewModel)
    func offerSelected(_ viewModel: OfferEntity)
    func setOffersLocations(_ locations: [PullOfferLocation], key: String)
    func setWithRecovery(_ recovery: Bool)
    func pendingRequestSelected(_ viewModel: PendingSolicitudeViewModel)
}

final class PendingSolicitudesPresenter {
    
    weak var view: PendingSolicitudesViewProtocol?
    private var pendingSolicitudes: [PendingSolicitudeEntity] = []
    private var candidateOffer: (location: PullOfferLocation, offer: OfferEntity)?
    private var recoveryOffer: (location: PullOfferLocation, offer: OfferEntity)?
    private var recovery: RecoveryEntity? {
        didSet {
            self.view?.observeBecomeActive()
        }
    }
    private let dependenciesResolver: DependenciesResolver
    private struct Constants {
        static var locations = PullOffersLocationsFactoryEntity().pendingRequestPG
        static var recoveryLocations = PullOffersLocationsFactoryEntity().pendingRequestRecovery
    }
    private var withRecoveryCell = true
    private var offerKey = GlobalPositionPullOffers.contractsInboxPG
    private var recoveryOfferKey = GlobalPositionPullOffers.recoveryN2
    
    enum PendingSolicitudeError: Error {
        case noCandidateOffer
        case pendingSolicitudeLoadingError
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension PendingSolicitudesPresenter: PendingSolicitudesPresenterProtocol {
    
    func viewDidLoad() {
        let viewModels = self.carouselViewModels()
        self.view?.showPendingSolicitudes(viewModels)
        self.expandViewIfNeeded()
    }
    
    func shouldShow(_ shouldShow: @escaping (Bool) -> Void) {
        let functions = [self.loadOffer,
                         self.loadPendingSolicitudes]
        self.does(functions) { [weak self] result in
            self?.getRecoveryInfo(result, shouldShow)
        }
    }
    
    func getRecoveryInfo(_ previous: Bool, _ completion: @escaping (Bool) -> Void) {
        guard withRecoveryCell == true else { return completion(previous) }
        self.loadRecoveryOffer { [weak self] in
            self?.loadRecovery({ resp in
                completion(previous || resp)
            })
        }
    }
    
    func pendingSolicitudeClosed(_ viewModel: PendingSolicitudeViewModel) {
        self.pendingSolicitudes.removeAll(where: { $0 == viewModel.entity })
        self.updatePendingSolicitude(viewModel.entity)
        let viewModels = self.carouselViewModels()
        guard viewModels.count > 0 else {
            self.view?.hide(completion: nil)
            return
        }
        self.view?.showPendingSolicitudes(viewModels)
    }
    
    func pendingSolicitudeSelected(_ viewModel: PendingSolicitudeViewModel) {
        self.pendingSolicitudeClosed(viewModel)
        self.dependenciesResolver.resolve(for: GlobalPositionModuleCoordinatorDelegate.self).didSelectOffer(viewModel.offer)
    }
    
    func offerSelected(_ offer: OfferEntity) {
        trackEvent(.manageDebt, parameters: [:])
        self.dependenciesResolver.resolve(for: GlobalPositionModuleCoordinatorDelegate.self).didSelectOffer(offer)
    }
    
    func pendingRequestSelected(_ viewModel: PendingSolicitudeViewModel) {
        self.removeSavedPendingSolicitudes(viewModel.entity)
        self.dependenciesResolver.resolve(for: GlobalPositionModuleCoordinatorDelegate.self).didSelectOffer(viewModel.offer)
    }
    
    func setOffersLocations(_ locations: [PullOfferLocation], key: String) {
        Constants.locations = locations
        self.offerKey = key
    }
    
    func setWithRecovery(_ recovery: Bool) {
        self.withRecoveryCell = recovery
    }
}

extension PendingSolicitudesPresenter: AutomaticScreenActionTrackable {
    public var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    public var trackerPage: RecoveryCarrouselPage {
        return RecoveryCarrouselPage()
    }
}

private extension PendingSolicitudesPresenter {
    
    func expandViewIfNeeded() {
        guard recovery != nil else { return }
        self.view?.expandView()
    }
    
    func carouselViewModels() -> [StickyButtonCarrouselViewModelProtocol] {
        return recoveryViewModel() + pendingViewModels()
    }
    
    func recoveryViewModel() -> [StickyButtonCarrouselViewModelProtocol] {
        guard let recoveryEntity = recovery else { return [] }
        trackScreen()
        let viewModel = processRecoveryEntity(recoveryEntity)
        return [viewModel]
    }
    
    func processRecoveryEntity(_ entity: RecoveryEntity) -> RecoveryViewModel {
        let amount = Decimal(-entity.amount).decorateAmount("€")
        let viewModel = RecoveryViewModel(debtCount: entity.debtCount,
                                          debtTitle: entity.debtTitle,
                                          amount: amount,
                                          offer: entity.offer,
                                          location: entity.location)
        return viewModel
    }
    
    func pendingViewModels() -> [StickyButtonCarrouselViewModelProtocol] {
        guard let offer = self.candidateOffer, self.pendingSolicitudes.count > 0 else { return [] }
        return self.pendingSolicitudes.map {
            PendingSolicitudeViewModel(entity: $0, offer: offer.offer, location: offer.location)
        }
    }
    
    var getPullOffersUseCase: GetPullOffersUseCase {
        return self.dependenciesResolver.resolve()
    }
    
    var getPendingSolicitudesUseCase: GetPendingSolicitudesUseCase {
        return self.dependenciesResolver.resolve()
    }
    
    var getRecoveryLevelUseCase: GetRecoveryLevelUseCase {
        return self.dependenciesResolver.resolve()
    }
    
    var updatePendingSolicitudeUseCase: UpdatePendingSolicitudeUseCase {
        return self.dependenciesResolver.resolve()
    }
    
    var removeSavedPendingSolicitudesUseCase: RemoveSavedPendingSolicitudesUseCase {
        return self.dependenciesResolver.resolve()
    }
    
    func updatePendingSolicitude(_ pendingSolicitude: PendingSolicitudeEntity) {
        MainThreadUseCaseWrapper(with: self.updatePendingSolicitudeUseCase.setRequestValues(requestValues: UpdatePendingSolicitudeUseCaseInput(pendingSolicitude: pendingSolicitude)))
    }
    
    func removeSavedPendingSolicitudes(_ pendingSolicitude: PendingSolicitudeEntity) {
        MainThreadUseCaseWrapper(with: self.removeSavedPendingSolicitudesUseCase)
    }
    
    func loadPendingSolicitudes(_ completion: @escaping (Bool) -> Void) {
        UseCaseWrapper(
            with: self.getPendingSolicitudesUseCase,
            useCaseHandler: self.dependenciesResolver.resolve(),
            onSuccess: { [weak self] result in
                self?.pendingSolicitudes = result.pendingSolicitudes
                completion(result.pendingSolicitudes.count > 0)
            },
            onError: { _ in
                completion(false)
        }
        )
    }
    
    func loadOffer(_ completion: @escaping (Bool) -> Void) {
        UseCaseWrapper(
            with: self.getPullOffersUseCase.setRequestValues(requestValues: GetPullOffersUseCaseInput(locations: Constants.locations)),
            useCaseHandler: self.dependenciesResolver.resolve(),
            onSuccess: { [weak self] offers in
                guard let offerKey = self?.offerKey,
                      let location = offers.pullOfferCandidates.location(key: offerKey)
                else { return completion(false) }
                self?.candidateOffer = (location.location, location.offer)
                completion(true)
            },
            onError: { _ in
                completion(true)
        }
        )
    }
    
    func loadRecoveryOffer(_ completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: self.getPullOffersUseCase.setRequestValues(requestValues: GetPullOffersUseCaseInput(locations: Constants.recoveryLocations)),
            useCaseHandler: self.dependenciesResolver.resolve(),
            onSuccess: { [weak self] offers in
                guard let offerKey = self?.recoveryOfferKey,
                    let location = offers.pullOfferCandidates.location(key: offerKey) else { return completion() }
                self?.recoveryOffer = (location.location, location.offer)
                completion()
            },
            onError: { _ in
                completion()
        }
        )
    }
    
    func loadRecovery(_ completion: @escaping (Bool) -> Void) {
        UseCaseWrapper(
            with: self.getRecoveryLevelUseCase,
            useCaseHandler: self.dependenciesResolver.resolve(),
            onSuccess: { [weak self] result in
                self?.recovery = RecoveryEntity(debtCount: result.debtCount,
                                                debtTitle: result.debtTitle,
                                                amount: result.amount,
                                                offer: self?.recoveryOffer?.offer,
                                                location: self?.recoveryOffer?.location,
                                                level: result.level)
                completion(true)
            },
            onError: { _ in
                completion(false)
        }
        )
    }
    
    typealias BooleanFunction = (Bool) -> Void
    
    /// Gets an array of functions with a Bool completion, an execute it recursively until one returns false or every function returns true
    /// - Parameters:
    ///   - functions: The array of functions to execute
    ///   - completion: The completion to return a boolean value
    func does(_ functions: [(@escaping BooleanFunction) -> Void], completion: @escaping BooleanFunction) {
        guard let function = functions.first else { return completion(true) }
        function { result in
            guard result == true else { return completion(false) }
            self.does(Array(functions.dropFirst()), completion: completion)
        }
    }
}
