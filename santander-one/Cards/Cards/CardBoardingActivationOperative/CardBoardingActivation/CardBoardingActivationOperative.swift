//
//  CardBoardingActivationOperative.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 06/10/2020.
//

import Foundation
import Operative
import CoreFoundationLib
import UI
import SANLegacyLibrary
import CoreDomain

final class CardBoardingActivationOperative: Operative {
    var dependencies: DependenciesInjector & DependenciesResolver
    var steps: [OperativeStep] = []
    weak var container: OperativeContainerProtocol?
    lazy var operativeData: CardBoardingActivationOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
          self.dependencies.resolve(for: CardBoardingActivationFinishingCoordinatorProtocol.self)
    }()
    private var sca: SCA? {
        let entity: SCAEntity? = self.container?.getOptional()
        return entity?.sca
    }
    
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
    
    enum FinishingOption {
        case goToCardBoarding
        case globalPosition
        case goToCardHome
        case goToReceivePin
    }
    
    private func setupDependencies() {
        self.setupUsecase()
        self.setupStartUsingCard()
        self.setupSignature()
        self.setupActivateCardSummary()
    }
    
    private func buildSteps() {
        self.steps.append(StartUsingCardStep(dependenciesResolver: dependencies))
        self.sca?.prepareForVisitor(self)
        self.steps.append(ActivateCardSummaryStep(dependenciesResolver: dependencies))
    }
}

extension CardBoardingActivationOperative: OperativeSetupCapable {
    
    func performSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let container = self.container else {
            failed(OperativeSetupError(title: nil, message: nil))
            return
        }
        let input = SetupActivateCardUseCaseInput(card: self.operativeData.selectedCard)
        let setupUsecase = self.dependenciesResolver.resolve(firstTypeOf: SetupActivateCardUseCaseProtocol.self)
        Scenario(useCase: setupUsecase, input: input)
            .execute(on: dependencies.resolve())
            .onSuccess { [weak self] result in
                container.save(result.scaEntity)
                self?.buildSteps()
                success()
            }.onError { error in
                failed(OperativeSetupError(title: nil, message: error.getErrorDesc()))
            }
    }
}

extension CardBoardingActivationOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        self.dependencies
    }
}

extension CardBoardingActivationOperative: OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        self.signAndConfirmActivateCredidAndDebitCards(for: presenter, completion: completion)
    }
    
    var isProgressBarEnabled: Bool {
        return false
    }
}

private extension CardBoardingActivationOperative {
    
    func signAndConfirmActivateCredidAndDebitCards(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard
            let signature: SignatureRepresentable = self.container?.get()
        else {
            return completion(false, nil)
        }
        let input = SignCardBoardingActivationUseCaseInput(
            card: self.operativeData.selectedCard,
            signature: signature
        )
        UseCaseWrapper(
             with: self.dependencies.resolve(for: SignCardBoardingActivationUseCase.self).setRequestValues(requestValues: input),
             useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
             onSuccess: { _ in
                 completion(true, nil)
             },
             onError: { errorResult in
                 switch errorResult {
                 case .error(let signatureError): completion(false, signatureError)
                 default: completion(false, nil)
                 }
             }
         )    }
}

extension CardBoardingActivationOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        return CardBoardingActivationSignaturePage().page
    }
}

extension CardBoardingActivationOperative: OperativeFinishingCoordinatorCapable {}

extension CardBoardingActivationOperative: SCACapable {}

extension CardBoardingActivationOperative: SCASignatureCapable {
    func prepareForSignature(_ signature: SignatureRepresentable) {
        self.container?.save(signature)
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
    }
}
