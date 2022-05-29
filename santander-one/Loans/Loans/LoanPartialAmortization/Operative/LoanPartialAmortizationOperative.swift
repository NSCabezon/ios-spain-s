import Foundation
import Operative
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

final class LoanPartialAmortizationOperative: Operative {
    var dependencies: DependenciesInjector & DependenciesResolver
    var steps: [OperativeStep] = []
    weak var container: OperativeContainerProtocol? {
        didSet { self.buildSteps() }
    }
    lazy var operativeData: LoanPartialAmortizationOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        self.dependencies.resolve(for: LoanPartialAmortizationFinishingCoordinatorProtocol.self)
    }()
    
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
}

private extension LoanPartialAmortizationOperative {
    func setupDependencies() {
        self.setupSelectAmortizationStep()
        self.setupConfirmAmortizationStep()
        self.setupSummaryAmortizationStep()
        self.setupUseCases()
    }
    
    func buildSteps() {
        self.steps.append(SelectAmortizationStep(dependenciesResolver: dependencies))
        self.steps.append(ConfirmationAmortizationStep(dependenciesResolver: dependencies))
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
        self.steps.append(SummaryAmortizationStep(dependenciesResolver: dependencies))
    }
}

extension LoanPartialAmortizationOperative: OperativeRebuildStepsCapable {
    func rebuildSteps() {
        self.steps.append(SelectAmortizationStep(dependenciesResolver: dependencies))
        self.steps.append(ConfirmationAmortizationStep(dependenciesResolver: dependencies))
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
        self.steps.append(SummaryAmortizationStep(dependenciesResolver: dependencies))
    }
}

extension LoanPartialAmortizationOperative: OperativeFinishingCoordinatorCapable {}

extension LoanPartialAmortizationOperative: OperativePresetupCapable {
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let container = self.container else { return }
        let loan = self.operativeData.selectedLoan
        let operativesConfig: OperativeConfig = container.get()
        let phoneNumber = operativesConfig.signatureSupportPhone
        let useCase = self.dependencies.resolve(for: SetupLoanPartialAmortizationUseCaseProtocol.self)
        let requestValues = SetupLoanPartialAmortizationUseCaseInput(loan: loan)
        Scenario(useCase: useCase, input: requestValues)
            .execute(on: self.dependencies.resolve())
            .onSuccess { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.operativeData.selectedLoanDetail = result.loanDetail
                strongSelf.operativeData.account = result.account
                strongSelf.operativeData.signatureSupportPhone = phoneNumber
                strongSelf.container?.save(strongSelf.operativeData)
                success()
            }
            .onError { error in
                failed(OperativeSetupError(title: nil, message: error.getErrorDesc()))
            }
    }
}

extension LoanPartialAmortizationOperative: OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container,
              let loanPartialAmortization = operativeData.partialAmortization,
              let amountTypeAmortization = operativeData.amortizationType,
              let loanValidation = operativeData.partialLoanAmortizationValidation,
              let signature: SignatureRepresentable = container.get(),
              let selectedAmount = operativeData.amortizationAmount else { return }
        let input = ConfirmLoanPartialAmortizationUseCaseInput(loanPartialAmortization: loanPartialAmortization,
                                                               amortizationType: amountTypeAmortization,
                                                               loanValidation: loanValidation,
                                                               signature: signature,
                                                               amount: selectedAmount)
        let useCase = self.dependenciesResolver.resolve(for: ConfirmLoanPartialAmortizationUseCaseProtocol.self)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { _ in
                completion(true, nil)
            }
            .onError { error in
                completion(false, GenericErrorSignatureErrorOutput(error.getErrorDesc(), .otherError, error.localizedDescription))
            }
    }
}

extension LoanPartialAmortizationOperative: OperativeSignatureNavigationCapable {
    var signatureNavigationTitle: String {
        return "summary_title_anticipatedAmortization"
    }
}

extension LoanPartialAmortizationOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
}

extension LoanPartialAmortizationOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "Amortiza_Prestamos")
    }
}

extension LoanPartialAmortizationOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-amort-parcial-abandono")
    }
}

extension LoanPartialAmortizationOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return dependencies.resolve(for: TrackerManager.self)
    }
    
    var extraParametersForTracker: [String: String] {
        return [:]
    }
}

extension LoanPartialAmortizationOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        return LoanPartialAmortizationSignaturePage().page
    }
}

extension LoanPartialAmortizationOperative: OperativeDialogFinishCapable {}
