//
//  SecurityAreaPresenter+Extension.swift
//  PersonalArea
//
//  Created by Juan Carlos López Robles on 2/3/20.
//

import Foundation
import CoreFoundationLib
import UI

extension SecurityAreaPresenter {
    var personalAreaDataManager: PersonalAreaDataManagerProtocol {
        return self.dependenciesResolver.resolve(for: PersonalAreaDataManagerProtocol.self)
    }
    var coordinatorDelegate: SecurityAreaCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: SecurityAreaCoordinatorDelegate.self)
    }
    var coordinator: SecurityAreaCoordinatorProtocol {
        return dependenciesResolver.resolve(for: SecurityAreaCoordinatorProtocol.self)
    }
    var locationPermission: LocationPermission {
        self.dependenciesResolver.resolve(for: LocationPermission.self)
    }
    var getPersonalBasicInfoUseCase: GetPersonalBasicInfoUseCaseProtocol {
        return self.dependenciesResolver.resolve(firstTypeOf: GetPersonalBasicInfoUseCaseProtocol.self)
    }
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    var getSecurityTipsUseCase: GetSecurityTipsUseCase {
        return self.dependenciesResolver.resolve(for: GetSecurityTipsUseCase.self)
    }
    var getValidatedDeviceUseCase: GetValidatedDeviceUseCase {
        return self.dependenciesResolver.resolve(for: GetValidatedDeviceUseCase.self)
    }
    var baseUrlProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    private var getContactPhonesUseCase: GetContactPhonesUseCaseProtocol {
        return self.dependenciesResolver.resolve(firstTypeOf: GetContactPhonesUseCaseProtocol.self)
    }
    private var getTripModeEnabledUseCase: GetTripModeEnabledUseCase {
        return self.dependenciesResolver.resolve(for: GetTripModeEnabledUseCase.self)
    }
    private var getOtpPushEnabledUseCase: GetOtpPushEnabledUseCase {
        return self.dependenciesResolver.resolve(for: GetOtpPushEnabledUseCase.self)
    }
    private var lastAccessInfoManager: LastAccessInfoManagerProtocol {
        return self.dependenciesResolver.resolve(for: LastAccessInfoManagerProtocol.self)
    }
    private var getHasOneProductsUseCase: GetHasOneProductsUseCase {
        return self.dependenciesResolver.resolve(for: GetHasOneProductsUseCase.self)
    }
    private var pullOfferUseCase: GetPullOffersUseCase {
        return self.dependenciesResolver.resolve(for: GetPullOffersUseCase.self)
    }
    
    func getGlobaViewInfoData(completion: @escaping () -> Void) {
        lastAccessInfoManager.getLastAccessDateViewModelIfAvailable { [weak self] viewModel in
            guard let self = self else { return }
            self.lastLogonViewModel = viewModel            
            let contactPhones: Scenario<Void, GetContactPhonesUseCaseOutput, StringErrorOutput> = Scenario(useCase: self.getContactPhonesUseCase)
            let tripModeEnabled: Scenario<Void, GetTripModeEnabledUseCaseOutput, StringErrorOutput> = Scenario(useCase: self.getTripModeEnabledUseCase)
            let otpPushEnabled: Scenario<Void, GetOtpPushEnabledUseCaseOutput, StringErrorOutput> = Scenario(useCase: self.getOtpPushEnabledUseCase)
            let offersScenario: Scenario<GetPullOffersUseCaseInput, GetPullOffersUseCaseOutput, StringErrorOutput> = Scenario(useCase: self.pullOfferUseCase, input: GetPullOffersUseCaseInput(locations: self.locations))
            let values: (fraudViewModel: PhoneViewModel?,
                         cardBlockViewModel: [PhoneViewModel]?,
                         tripModeEnabled: Bool?,
                         otpPushEnabled: Bool?,
                         pullOfferCandidates: [PullOfferLocation: OfferEntity]?) = (nil, nil, nil, nil, nil)
            MultiScenario(handledOn: self.dependenciesResolver.resolve(), initialValue: values)
                .addScenario(contactPhones) { (updatedValues, output, _) in
                    updatedValues.fraudViewModel = output.fraude.numbers?.map(PhoneViewModel.init).first ?? PhoneViewModel(phone: "")
                    updatedValues.cardBlockViewModel = output.cardBlock.numbers?.map(PhoneViewModel.init) ?? []
                }
                .addScenario(tripModeEnabled) { (updatedValues, output, _) in
                    updatedValues.tripModeEnabled = output.tripModeEnabled
                }
                .addScenario(otpPushEnabled) { (updatedValues, output, _) in
                    updatedValues.otpPushEnabled = output.otpPushEnabled
                }
                .addScenario(offersScenario) { (updatedValues, output, _) in
                    updatedValues.pullOfferCandidates = output.pullOfferCandidates
                }
                .asScenarioHandler()
                .onSuccess { [weak self] result in
                    self?.fraudViewModel = result.fraudViewModel
                    self?.cardBlockViewModel = result.cardBlockViewModel
                    self?.isTripModeEnabled = result.tripModeEnabled
                    self?.isOtpPushEnabled = result.otpPushEnabled
                    self?.offers = result.pullOfferCandidates ?? [:]
                }
                .then(scenario: { _ in
                    Scenario(useCase: self.getHasOneProductsUseCase, input: GetHasOneProductsUseCaseInput(product: \.securityOneProducts))
                })
                .onSuccess { [weak self] result in
                    guard (self?.offers.contains(location: SecurityAreaPullOffers.onlineProtection)) != nil else {
                        self?.isProtectionViewEnabled = false
                        return
                    }
                    self?.isProtectionViewEnabled = result.hasOneProduct
                }
                .then(scenario: { _ in
                    Scenario(useCase: self.getHasOneProductsUseCase, input: GetHasOneProductsUseCaseInput(product: \.safeOneProducts))
                })
                .onSuccess { [weak self] result in
                    guard (self?.someSafeBoxOfferIsValid()) != nil else { return }
                    let selectedOfferKey = result.hasOneProduct ? SecurityAreaPullOffers.safeBoxSecurity : SecurityAreaPullOffers.safeBoxSecurityNoOne
                    self?.safeBoxOfferKey = selectedOfferKey
                    let safeBoxOffer = self?.offers.location(key: selectedOfferKey)?.offer
                    self?.isPasswordViewEnabled = safeBoxOffer != nil
                }
                .finally {
                    completion()
                }
        }
    }

    func getPersonalInformation(_ completion: @escaping (PersonalInformationEntity?) -> Void) {
        UseCaseWrapper(
            with: getPersonalBasicInfoUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { result in
                completion(result.personalInformation)
            }, onError: { _ in
                completion(nil)
        })
    }
    
    func getSecurityTips() {
        UseCaseWrapper(
            with: getSecurityTipsUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                let viewModels = result.securityTips?.map {
                    return HelpCenterTipViewModel($0, baseUrl: self?.baseUrlProvider.baseURL)
                }
                self?.view?.setSecurityTips(viewModels ?? [])
            }, onError: {[weak self] _ in
                self?.view?.setSecurityTips([])
        })
    }
    
    func getValidatedDeviceState(_ completion: @escaping (ValidatedDeviceStateEntity) -> Void) {
        UseCaseWrapper(
            with: getValidatedDeviceUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { result in
                completion(result.state)
            }, onError: {_ in
                completion(.notRegisteredDevice)
        })
    }
    
    func someSafeBoxOfferIsValid() -> Bool {
        return self.offers.contains(location: SecurityAreaPullOffers.safeBoxSecurity) || self.offers.contains(location: SecurityAreaPullOffers.safeBoxSecurityNoOne)
    }
    
    func setOfferConfiguration() {
        self.setAlertConfiguration()
        self.setThirdPartyPermissionsVisibility()
    }
}

private extension SecurityAreaPresenter {

    func setAlertConfiguration() {
        let offer = self.offers.location(key: SecurityAreaPullOffers.personalAreaAlert)?.offer
        let viewModel = SecurityActionFactory.getAlertConfiguration(offer)
        self.alertSecurityViewModel = viewModel
    }
    
    func setThirdPartyPermissionsVisibility() {
        let permissionOffer = self.offers.location(key: SecurityAreaPullOffers.thirtPartyPermissions)?.offer
        self.isThirdPartyPermissionsHidden = permissionOffer == nil
    }
}

extension SecurityAreaPresenter: GlobalSecurityViewDelegate {
    func didSelectCallNow(_ phoneNumber: String) {
        self.trackEvent(.fraud, parameters: [.tfno: phoneNumber])
        self.coordinatorDelegate.didSelectCallPhoneNumber(phoneNumber)
    }
    
    func didSelectStoleCall(_ phoneNumber: String) {
        self.trackEvent(.stole, parameters: [.tfno: phoneNumber])
        self.coordinatorDelegate.didSelectCallPhoneNumber(phoneNumber)
    }
    
    func didSelectSecureDevice() {
        self.trackEvent(.otpPush, parameters: [:])
        self.state = .shouldLoad
        self.coordinator.goToSecureDevice()
    }
    
    func didSelectConfigureAlerts() {
        let offer = self.offers.location(key: SecurityAreaPullOffers.personalAreaAlert)?.offer
        self.coordinatorDelegate.didSelectOffer(offer)
    }
    
    func didSelectPermission() {
        if let permissionOffer = self.offers.location(key: SecurityAreaPullOffers.thirtPartyPermissions)?.offer {
            self.coordinatorDelegate.didSelectOffer(permissionOffer)
        }
    }
    
    func didSelectTravel() {
        trackEvent(.trips, parameters: [:])
        self.coordinator.didSelectTravel()
    }
    
    func didSelectOnlineProtection() {
        let offer = self.offers.location(key: SecurityAreaPullOffers.onlineProtection)?.offer
        self.coordinatorDelegate.didSelectOffer(offer)
    }
    
    func didSelectSafeBox() {
        guard let safeBoxOfferKey = self.safeBoxOfferKey,
              let offer = self.offers.location(key: safeBoxOfferKey)?.offer
        else { return }
        self.coordinatorDelegate.didSelectOffer(offer)
    }
    
    func showToast() {
        self.coordinator.showToast()
    }
}
