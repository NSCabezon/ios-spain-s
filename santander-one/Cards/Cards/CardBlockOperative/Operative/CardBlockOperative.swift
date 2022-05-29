//
//  CardBlockOperative.swift
//  Cards
//
//  Created by Laura González on 27/05/2021.
//

import Foundation
import Operative
import CoreFoundationLib
import CoreDomain

final class CardBlockOperative: Operative {
    var dependencies: DependenciesInjector & DependenciesResolver
    var steps: [OperativeStep] = []
    weak var container: OperativeContainerProtocol?
    lazy var operativeData: CardBlockOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        self.dependencies.resolve(for: CardBlockFinishingCoordinatorProtocol.self)
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
    
    enum FinishingOption {
        case cardsHome
        case globalPosition
    }
}

private extension CardBlockOperative {
    func setupDependencies() {
        self.setupCardBlockReason()
        self.setupCardBlockSummary()
        self.setupUseCases()
    }
    
    func buildSteps() {
        self.steps.append(CardBlockReasonStep(dependenciesResolver: dependencies))
        self.appendPredefinedSCASteps()
        self.steps.append(CardBlockSummaryStep(dependenciesResolver: dependencies))
    }
    
    private func appendPredefinedSCASteps() {
        switch self.predefinedSCA {
        case .signature:
            self.steps.append(SignatureStep(dependenciesResolver: dependencies))
        case .otp, .signatureAndOtp, .none:
            break
        }
    }
}

extension CardBlockOperative: OperativeRebuildStepsCapable {
    func rebuildSteps() {
        self.steps.append(CardBlockReasonStep(dependenciesResolver: dependencies))
        self.sca?.prepareForVisitor(self)
        self.steps.append(CardBlockSummaryStep(dependenciesResolver: dependencies))
    }
}

extension CardBlockOperative: OperativeFinishingCoordinatorCapable {}

extension CardBlockOperative: SCACapable { }

extension CardBlockOperative: OperativePresetupCapable {
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let container = self.container else {
            return failed(OperativeSetupError(title: nil, message: nil))
        }
        let useCase = self.dependencies.resolve(for: SetupCardBlockUseCaseProtocol.self)
        Scenario(useCase: useCase)
            .execute(on: self.dependencies.resolve())
            .onSuccess { [weak self] result in
                container.save(result.predefinedSCAEntity)
                self?.buildSteps()
                success()
            }
            .onError { error in
                failed(OperativeSetupError(title: nil, message: error.getErrorDesc()))
            }
    }
}

extension CardBlockOperative: SCASignatureCapable {
    func prepareForSignature(_ signature: SignatureRepresentable) {
        self.container?.save(signature)
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
    }
}

extension CardBlockOperative: OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let signature: SignatureRepresentable = self.container?.get(),
              let card = operativeData.selectedCard,
              let reason = operativeData.blockType
        else {
            return completion(false, nil)
        }
        let useCase = self.dependencies.resolve(for: ConfirmCardBlockUseCaseProtocol.self)
        let input = ConfirmCardBlockUseCaseInput(card: card,
                                                 blockCardStatus: reason,
                                                 blockText: operativeData.comment ?? "",
                                                 signature: signature)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { [weak self] response in
                self?.operativeData.deliveryAddress = response.deliveryAddress
                self?.container?.save(self?.operativeData)
                completion(true, nil)
            }
            .onError { errorResult in
                switch errorResult {
                case .error(error: let signatureError): completion(false, signatureError)
                default: completion(false, nil)
                }
            }
    }
}

extension CardBlockOperative: OperativeSignatureNavigationCapable {
    var signatureNavigationTitle: String {
        return "toolbar_title_blockCard"
    }
}

extension CardBlockOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
}

extension CardBlockOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-bloqueo-tarjetas-exito")
    }
}

extension CardBlockOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-bloqueo-tarjetas-abandono")
    }
}

extension CardBlockOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return dependencies.resolve(for: TrackerManager.self)
    }
    
    var extraParametersForTracker: [String: String] {
        return [:]
    }
}

extension CardBlockOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        return CardBlockSignaturePage().page
    }
}
