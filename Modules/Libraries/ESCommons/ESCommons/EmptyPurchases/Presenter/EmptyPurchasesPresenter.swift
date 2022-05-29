//
//  EcommerceEmptyPurchasesPresenter.swift
//  Ecommerce
//
//  Created by Alvaro Royo on 25/3/21.
//

import CoreFoundationLib

public protocol EmptyPurchasesPresenterProtocol {
    var view: EcommerceEmptyPurchasesProtocol? { get set }
    func viewDidLoad()
    func showEcommerceLocation()
    func setSecureDevice(viewModel: EcommerceSecureDeviceViewModel)
    func didTapRegisterSecureDevice()
}

public protocol EmptyPurchasesPresenterDelegate {
    func didSelectOffer(_ offer: OfferEntity)
    func registerSecureDeviceDeepLink()
}

public final class EmptyPurchasesPresenter: EmptyPurchasesPresenterProtocol {
    weak public var view: EcommerceEmptyPurchasesProtocol?
    private let dependenciesResolver: DependenciesResolver
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
    private var secureDeviceViewModel: EcommerceSecureDeviceViewModel?
    var pageAssociated: EcommerceSantanderKeyPageProtocol?

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func viewDidLoad() {
        loadOffers()
        if let viewModel = self.secureDeviceViewModel {
            // Track screen only when it show secure device view
            self.trackScreen()
            self.view?.showSecureDevice(viewModel)
        }
    }
    
    public func setSecureDevice(viewModel: EcommerceSecureDeviceViewModel) {
        self.secureDeviceViewModel = viewModel
        self.pageAssociated = viewModel.pageStrategy
    }
    
    public func didTapRegisterSecureDevice() {
        self.trackRegisterSecureDevice()
        self.delegate?.registerSecureDeviceDeepLink()
        if !sessionManager.isSessionActive {
            self.view?.showTopAlert(text: localized("login_alert_registerSantanderKey"))
        }
    }
}

private extension EmptyPurchasesPresenter {
    var delegate: EmptyPurchasesPresenterDelegate? {
        return self.dependenciesResolver.resolve(for: EmptyPurchasesPresenterDelegate.self)
    }
    
    var sessionManager: CoreSessionManager {
        return self.dependenciesResolver.resolve(for: CoreSessionManager.self)
    }
    
    var getPullOffersCandidatesUseCase: PullOfferCandidatesUseCase {
        self.dependenciesResolver.resolve()
    }
    
    var locations: [PullOfferLocation] {
        if sessionManager.isSessionActive {
            return PullOffersLocationsFactoryEntity().ecommerce.filter({ $0.stringTag == EcommerceConstants.privateTutorial })
        } else {
            return PullOffersLocationsFactoryEntity().ecommerce.filter({ $0.stringTag == EcommerceConstants.publicTutorial })
        }
    }
    
    var selectedOffer: OfferEntity? {
        var tag: String
        if sessionManager.isSessionActive {
            tag = CoreFoundationLib.EcommerceConstants.privateTutorial
        } else {
            tag = CoreFoundationLib.EcommerceConstants.publicTutorial
        }
        guard let location = (locations.first{ $0.stringTag == tag }),
              let offer = pullOfferCandidates?[location]
        else { return nil }
        return offer
    }
    
    var hasOffer: Bool {
        return selectedOffer != nil
    }
    
    func reloadView() {
        self.view?.hideOffer(!hasOffer)
    }
    
    func trackRegisterSecureDevice() {
        if let status = self.pageAssociated?.statusSecureDevice {
            switch status {
            case .update:
                self.trackEvent(.updateButton)
            case .register:
                self.trackEvent(.registerButton)
            }
        }
    }
}

// MARK: - Locations
extension EmptyPurchasesPresenter {
    private func loadOffers() {
        Scenario(useCase: getPullOffersCandidatesUseCase, input: PullOfferCandidatesUseCaseInput(locations: locations))
            .execute(on: dependenciesResolver.resolve(for: UseCaseHandler.self))
            .onSuccess { [weak self] result in
                self?.pullOfferCandidates = result.candidates
                self?.reloadView()
        }
    }
    
    public func showEcommerceLocation() {
        guard let offer = selectedOffer else { return }
        self.delegate?.didSelectOffer(offer)
    }
}

extension EmptyPurchasesPresenter: AutomaticScreenActionTrackable {
    public var trackerPage: EcommerceSantanderKeyPage {
        EcommerceSantanderKeyPage(strategy: self.pageAssociated)
    }
    
    public var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
