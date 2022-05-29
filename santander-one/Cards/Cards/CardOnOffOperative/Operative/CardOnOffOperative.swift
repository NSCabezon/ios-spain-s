//
//  CardOnOffOperative.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 30/8/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import Operative

final class CardOnOffOperative: Operative {
    var dependencies: DependenciesInjector & DependenciesResolver
    var steps: [OperativeStep] = []
    weak var container: OperativeContainerProtocol?
    lazy var operativeData: CardOnOffOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        self.dependencies.resolve(for: CardOnOffFinishingCoordinatorProtocol.self)
    }()
    lazy var coordinator: CardOnOffFinishingCoordinatorProtocol = {
        self.dependencies.resolve(for: CardOnOffFinishingCoordinatorProtocol.self)
    }()
    private var isSelectedCardStepVisible: Bool = false
    private var sca: SCA? {
        let entity: SCAEntity? = self.container?.getOptional()
        return entity?.sca
    }
    
    private var predefinedSCA: PredefinedSCAEntity? {
        let entity: PredefinedSCAEntity? = self.container?.getOptional()
        return entity
    }
    
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
}

private extension CardOnOffOperative {
    func setupDependencies() {
        self.setupCardSelector()
        self.setupCardOnOffSummary()
        self.setupUseCases()
    }
    
    func setupCardSelector() {
        self.dependencies.register(for: CardSelectorStepPresenterProtocol.self) { resolver in
            return CardSelectorStepPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: CardSelectorStepViewProtocol.self) { resolver in
            return resolver.resolve(for: CardSelectorStepViewController.self)
        }
        self.dependencies.register(for: CardSelectorStepViewController.self) { resolver in
            let presenter = resolver.resolve(for: CardSelectorStepPresenterProtocol.self)
            let viewController = CardSelectorStepViewController(nibName: "\(CardSelectorStepViewController.self)", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupCardOnOffSummary() {
        self.dependencies.register(for: CardOnOffSummaryStepPresenterProtocol.self) { resolver in
            return CardOnOffSummaryStepPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: CardOnOffSummaryStepViewProtocol.self) { resolver in
            return resolver.resolve(for: CardOnOffSummaryStepViewController.self)
        }
        self.dependencies.register(for: CardOnOffSummaryStepViewController.self) { resolver in
            let presenter = resolver.resolve(for: CardOnOffSummaryStepPresenterProtocol.self)
            let viewController = CardOnOffSummaryStepViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupUseCases() {
        self.dependencies.register(for: PreSetupCardOnOffUseCaseProtocol.self) { resolver in
            return PreSetupCardOnOffUseCase(resolver: resolver)
        }
    }
    
    func buildSteps() {
        self.appendCardSelectorIfNeeded()
        self.appendPredefinedSCASteps()
        self.steps.append(CardOnOffSummaryStep(dependenciesResolver: dependencies))
    }
    
    func appendCardSelectorIfNeeded() {
        guard self.operativeData.selectedCard == nil else { return }
        self.steps.append(CardSelectorStep(dependenciesResolver: dependencies))
    }
    
    func appendPredefinedSCASteps() {
        switch self.predefinedSCA {
        case .signature:
            self.steps.append(SignatureStep(dependenciesResolver: dependencies))
        case .otp, .signatureAndOtp, .none:
            break
        }
    }
}

extension CardOnOffOperative: OperativeRebuildStepsCapable {
    func rebuildSteps() {
        self.sca?.prepareForVisitor(self)
        self.steps.append(CardOnOffSummaryStep(dependenciesResolver: dependencies))
    }
}

extension CardOnOffOperative: OperativeFinishingCoordinatorCapable {}

extension CardOnOffOperative: SCACapable {}

extension CardOnOffOperative: OperativeDialogFinishCapable {}

extension CardOnOffOperative: OperativePresetupCapable {
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        let predefineSCAUseCase = self.dependencies.resolve(for: GetCardOnOffPredefinedSCAUseCaseProtocol.self)
        let preSetupUsecase = self.dependencies.resolve(for: PreSetupCardOnOffUseCaseProtocol.self)
        let input = PreSetupCardOnOffUseCaseInput(card: operativeData.selectedCard, option: operativeData.option)
        let operativeData: CardOnOffOperativeData? = self.container?.get()
        Scenario(useCase: predefineSCAUseCase)
            .execute(on: DispatchQueue.main)
            .onSuccess { [weak self] result in
                self?.container?.save(result.predefinedSCAEntity)
                self?.buildSteps()
            }.then(scenario: {_ in
                Scenario(useCase: preSetupUsecase, input: input)
            }, scheduler: self.dependencies.resolve(for: UseCaseHandler.self))
            .onSuccess { [weak self] result in
                self?.operativeData.list = result.cards
                self?.container?.save(operativeData)
                success()
            }
            .onError { error in
                failed(OperativeSetupError(title: nil, message: error.getErrorDesc()))
            }
    }
}

extension CardOnOffOperative: OperativeSetupCapable {
    func performSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let card = operativeData.selectedCard else {
            success()
            return
        }
        let useCase = self.dependencies.resolve(for: ValidateCardOnOffUseCaseProtocol.self)
        let input = ValidateCardOnOffUseCaseInput(card: card, blockType: self.operativeData.option)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                self.container?.save(result.sca)
                self.sca?.prepareForVisitor(self)
                success()
            }
            .onError { error in
                failed(OperativeSetupError(title: nil, message: error.getErrorDesc()))
            }
    }
}

extension CardOnOffOperative: SCASignatureCapable {
    func prepareForSignature(_ signature: SignatureRepresentable) {
        self.container?.save(signature)
    }
}

extension CardOnOffOperative: OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let signature: SignatureRepresentable = self.container?.get(), let selectedCard = operativeData.selectedCard else {
            return completion(false, nil)
        }
        let useCase = self.dependencies.resolve(for: ConfirmCardOnOffUseCaseProtocol.self)
        let input = ConfirmCardOnOffUseCaseInput(card: selectedCard, signature: signature, localState: operativeData.option)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { [weak self] _ in
                self?.container?.save(self?.operativeData)
                completion(true, nil)
            }
            .onError { errorResult in
                switch errorResult {
                case .error(let error): completion(false, error)
                default: completion(false, nil)
                }
            }
    }
}

extension CardOnOffOperative: OperativeSignatureNavigationCapable {
    var signatureNavigationTitle: String {
        return operativeData.option == .turnOn ? localized("toolbar_button_turnOn") : localized("toolbar_button_turnOff")
    }
}

extension CardOnOffOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
}

extension CardOnOffOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-tarjeta-on-off-exito")
    }
}

extension CardOnOffOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-tarjeta-on-off-abandono")
    }
}

extension CardOnOffOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return dependencies.resolve(for: TrackerManager.self)
    }
    
    var extraParametersForTracker: [String: String] {
        return [TrackerDimension.cardType.key: operativeData.selectedCard?.trackId ?? ""]
    }
}

extension CardOnOffOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        return operativeData.option == .turnOn ? CardOnSignaturePage().page : CardOffSignaturePage().page
    }
}
