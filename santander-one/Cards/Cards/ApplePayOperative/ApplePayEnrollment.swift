//
//  ApplePayEnrollment.swift
//  Cards
//
//  Created by Jose Carlos Estela Anguita on 04/12/2019.
//

import Foundation
import PassKit
import CoreFoundationLib

public enum ApplePayError: Error {
    
    case notAvailable
    case unknown
    case description(String?)
    
    static func description(_ error: Error) -> ApplePayError {
        return .description(error.localizedDescription)
    }
}

public protocol ApplePayEnrollmentDelegate: AnyObject {
    func applePayEnrollmentDidFinishSuccessfully()
    func applePayEnrollmentDidFinishWithError(_ error: ApplePayError)
}

public protocol ApplePayOperativeViewLauncher: AnyObject {}

public class ApplePayEnrollmentManager: NSObject {
    
    private struct ApplePayEnrollmentEntity {
        let card: CardEntity
        let detail: CardDetailEntity
        let otpValidation: OTPValidationEntity
        let otpCode: String
        let completion: (Result<Void, Error>) -> Void
    }
    
    private let dependenciesResolver: DependenciesResolver
    private var currentEnrollment: ApplePayEnrollmentEntity?
    private var addToApplePayConfirmationUseCase: AddToApplePayConfirmationUseCase {
        // Change when this operative is in the module
        AddToApplePayConfirmationUseCase(dependenciesResolver: dependenciesResolver)
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private weak var delegate: ApplePayEnrollmentDelegate? {
        dependenciesResolver.resolve(for: ApplePayEnrollmentDelegate.self)
    }
    
    // MARK: - Private
    
    private func handleSuccess() {
        self.currentEnrollment?.completion(.success(Void()))
        self.currentEnrollment = nil
    }
    
    private func handleError(_ error: ApplePayError) {
        self.currentEnrollment?.completion(.failure(error))
        self.currentEnrollment = nil
        self.delegate?.applePayEnrollmentDidFinishWithError(error)
    }
}

extension ApplePayEnrollmentManager: ApplePayEnrollmentManagerProtocol {
    
    public func enrollCard(_ card: CardEntity, detail: CardDetailEntity, otpValidation: OTPValidationEntity, otpCode: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2)
        configuration?.cardholderName = detail.holder
        configuration?.primaryAccountSuffix = card.pan.substring(ofLast: 4)
        self.currentEnrollment = ApplePayEnrollmentEntity(card: card, detail: detail, otpValidation: otpValidation, otpCode: otpCode, completion: completion)
        guard
            let paymentConfiguration = configuration,
            let paymentPassViewController = PKAddPaymentPassViewController(requestConfiguration: paymentConfiguration, delegate: self)
        else {
            self.handleError(.notAvailable)
            return
        }
        let rootViewController: UIViewController?
        if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            rootViewController = presentedViewController
        } else {
            rootViewController = UIApplication.shared.keyWindow?.rootViewController
        }
        rootViewController?.present(paymentPassViewController, animated: true, completion: nil)
    }
    
    public func alreadyAddedPaymentPasses() -> [String] {
        return PKPassLibrary().passes(of: .payment).compactMap({ $0.paymentPass?.deviceAccountIdentifier })
    }
    
    public func isEnrollingCardEnabled() -> Bool {
        return PKAddPaymentPassViewController.canAddPaymentPass()
    }
}

extension ApplePayEnrollmentManager: PKAddPaymentPassViewControllerDelegate {
    
    public func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, generateRequestWithCertificateChain certificates: [Data], nonce: Data, nonceSignature: Data, completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {
        guard let currentEnrollment = self.currentEnrollment else { return }
        let useCase = self.addToApplePayConfirmationUseCase.setRequestValues(
            requestValues: AddToApplePayConfirmationUseCaseInput(
                card: currentEnrollment.card,
                detail: currentEnrollment.detail,
                otpValidation: currentEnrollment.otpValidation,
                otpCode: currentEnrollment.otpCode,
                encryptionScheme: "ECC",
                publicCertificates: certificates,
                nonce: nonce,
                nonceSignature: nonceSignature
            )
        )
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { result in
                let request = PKAddPaymentPassRequest()
                request.activationData = result.activationData
                request.encryptedPassData = result.encryptedPassData
                request.ephemeralPublicKey = result.ephemeralPublicKey
                request.wrappedKey = result.wrappedKey
                handler(request)
            },
            onError: { [weak self] error in
                controller.dismiss(animated: true) { [weak self] in
                    self?.handleError(ApplePayError.description(error.getErrorDesc()))
                }
            }
        )
    }
    
    public func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, didFinishAdding pass: PKPaymentPass?, error: Error?) {
        controller.dismiss(animated: true) { [weak self] in
            guard pass != nil else {
                self?.handleError(ApplePayError.unknown)
                return
            }
            self?.handleSuccess()
        }
    }
}
