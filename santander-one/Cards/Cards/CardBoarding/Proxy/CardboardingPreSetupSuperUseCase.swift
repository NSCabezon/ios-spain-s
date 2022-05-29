//
//  CardboardingPreSetupSuperUseCase.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/13/20.
//
import CoreFoundationLib
import Foundation

protocol CardboardingPreSetupSuperUseCaseDelegate: AnyObject {
    func didFinishSuccessfuly(_ configuration: CardboardingConfiguration)
    func didFinishWithError(error: UseCaseError<StringErrorOutput>)
}

final class CardboardingPreSetupSuperUseCaseHandler: SuperUseCaseDelegate {
    weak var delegate: CardboardingPreSetupSuperUseCaseDelegate?
    var configuration: CardboardingConfiguration?
    
    func onSuccess() {
        guard let configuration = self.configuration else {
            self.delegate?.didFinishWithError(error: .error(StringErrorOutput(nil)))
            return
        }
        self.delegate?.didFinishSuccessfuly(configuration)
    }
    
    func onError(error: String?) {
        self.delegate?.didFinishWithError(error: .error(StringErrorOutput(error)))
    }
}

final class CardboardingPreSetupSuperUseCase: SuperUseCase<CardboardingPreSetupSuperUseCaseHandler> {
    private let dependenciesResolver: DependenciesResolver
    private let config: CardboardingConfiguration
    private let handler: CardboardingPreSetupSuperUseCaseHandler?
    weak var handlerDelegate: CardboardingPreSetupSuperUseCaseDelegate? {
        get { return handler?.delegate }
        set { self.handler?.delegate = newValue}
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.config = self.dependenciesResolver.resolve(for: CardboardingConfiguration.self)
        let useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        self.handler = CardboardingPreSetupSuperUseCaseHandler()
        super.init(useCaseHandler: useCaseHandler, delegate: handler)
    }
    
    override func setupUseCases() {
        self.loadUpdatedCard()
    }
}

private extension CardboardingPreSetupSuperUseCase {
    var pushNotificationPermissionManager: PushNotificationPermissionsManagerProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self)
    }

    func loadUpdatedCard() {
        let useCase = self.dependenciesResolver.resolve(for: GetUpdatedCardUseCase.self).setRequestValues(requestValues: GetUpdatedCardUseCaseInput(card: self.config.selectedCard))
        self.add(useCase, isMandatory: true) { result in
            self.loadConfiguration(updatedCard: result.updatedCard)
        }
    }
    
    func loadConfiguration(updatedCard: CardEntity) {
        let useCase = self.dependenciesResolver.resolve(for: CardboardingConfigurationUseCase.self).setRequestValues(requestValues: CardboardingConfigurationUseCaseInput(selectedCard: updatedCard))
        self.add(useCase, isMandatory: false) { result in
            self.handler?.configuration = result.configuration
            self.loadPreSetup()
        }
    }
    
    func loadPreSetup() {
        self.getApplePaySupport()
        self.getPaymentMethod()
        self.getNotificationStatus()
        self.getGeolocationAuthorizationStatus()
    }
    
    func getApplePaySupport() {
        guard let selectedCard = self.handler?.configuration?.selectedCard else { return }
        let useCase = self.dependenciesResolver.resolve(for: GetCardApplePaySupportUseCase.self).setRequestValues(requestValues: GetCardApplePaySupportUseCaseInput(card: selectedCard))
        self.add(useCase, isMandatory: false) { result in
            self.handler?.configuration?.applePayState = result.applePayState
        }
    }
    
    func getPaymentMethod() {
        guard let selectedCard = self.handler?.configuration?.selectedCard else { return }
        let useCase = self.dependenciesResolver.resolve(for: GetCreditCardPaymentMethodUseCase.self).setRequestValues(requestValues: GetCreditCardPaymentMethodUseCaseInput(card: selectedCard))
        self.add(useCase, isMandatory: false) { result in
            self.handler?.configuration?.paymentMethod = result.changePayment
        }
    }
    
    func getNotificationStatus() {
        self.add { completion in
            self.pushNotificationPermissionManager?.isNotificationsEnabled { [weak self] (result) in
                self?.handler?.configuration?.pushNotificationEnabled = result
                completion()
            }
        }
    }
    
    func getGeolocationAuthorizationStatus() {
        self.add { completion in
            let locationPermission = self.dependenciesResolver.resolve(for: LocationPermission.self)
            self.handler?.configuration?.geolocationEnabled = locationPermission.isLocationAccessEnabled()
            completion()
        }
    }
}
