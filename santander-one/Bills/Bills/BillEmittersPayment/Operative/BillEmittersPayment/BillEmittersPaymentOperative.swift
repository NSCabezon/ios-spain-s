//
//  BillEmittersPaymentOperative
//  Bills
//
//  Created by Juan Carlos López Robles on 5/14/20.
//

import Foundation
import Operative
import CoreFoundationLib
import UI
import CoreDomain

final class BillEmittersPaymentOperative: Operative {
    var dependencies: DependenciesInjector & DependenciesResolver
    private var isSelectedAccountStepVisible: Bool = false
    var steps: [OperativeStep] = []
    weak var container: OperativeContainerProtocol? {
        didSet { self.buildSteps() }
    }
    lazy var operativeData: BillEmittersPaymentOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
          self.dependencies.resolve(for: BillEmittersPaymentFinishingCoordinatorProtocol.self)
    }()
    enum FinishingOption {
        case billsHome
        case globalPosition
    }
    
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
    
    private func setupDependencies() {
        self.setupPreSetup()
        self.setupAccountSelector()
        self.setupSearchEmitters()
        self.setupBillEmittersPaymentConfirmation()
        self.setupBillEmittersPaymentSummary()
        self.setupBillEmittersManualPayment()
        self.setupConfirmUseCase()
    }
    
    private func buildSteps() {
        self.addAccountSelectorStepIfNeeded()
        self.steps.append(SearchEmittersStep(dependenciesResolver: dependencies))
        self.steps.append(BillEmittersManualPaymentStep(dependenciesResolver: dependencies))
        self.steps.append(BillEmittersPaymentConfirmationStep(dependenciesResolver: dependencies))
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
        self.steps.append(BillEmittersPaymentSummaryStep(dependenciesResolver: dependencies))
    }
    
    private func addAccountSelectorStepIfNeeded() {
        if operativeData.selectedAccount == nil || isSelectedAccountStepVisible {
             self.steps.append(BillEmittersPaymentAccountSelectorStep(dependenciesResolver: dependencies))
             isSelectedAccountStepVisible = true
         }
    }
    
    private func setupPreSetup() {
        self.dependencies.register(for: PreSetupBillEmittersPaymentUseCase.self) { resolver in
            PreSetupBillEmittersPaymentUseCase(dependenciesResolver: resolver)
        }
    }
    
    private func setupConfirmUseCase() {
        self.dependencies.register(for: ConfirmBillEmittersPaymentUseCase.self) { resolver in
            ConfirmBillEmittersPaymentUseCase(dependenciesResolver: resolver)
        }
    }
}

extension BillEmittersPaymentOperative: OperativePresetupCapable {
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let container = self.container else {
            failed(OperativeSetupError(title: nil, message: nil))
            return
        }
        UseCaseWrapper(
            with: self.dependencies.resolve(for: PreSetupBillEmittersPaymentUseCase.self),
            useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
            onSuccess: { result in
                let operativeData: BillEmittersPaymentOperativeData = container.get()
                operativeData.accounts = result.accounts
                operativeData.faqs = result.faqs
                container.save(operativeData)
                success()
            },
            onError: { result in
                failed(OperativeSetupError(title: nil, message: result.getErrorDesc()))
            }
        )
    }
}

extension BillEmittersPaymentOperative: OperativeBackToStepCapable {
    
    func stepAdded(_ step: OperativeStep) {
        switch step {
        case is BillEmittersPaymentAccountSelectorStep:
            self.isSelectedAccountStepVisible = true
        default:
            break
        }
    }
}

extension BillEmittersPaymentOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        self.dependencies
    }
}

extension BillEmittersPaymentOperative: OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        self.signAndConfirmBillEmittersPayment(for: presenter, completion: completion)
    }
}

private extension BillEmittersPaymentOperative {
    func signAndConfirmBillEmittersPayment(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let input = self.setConfirmBillEmittersPaymentUseCaseInput() else {
            return completion(false, nil)
        }
        UseCaseWrapper(
            with: self.dependencies.resolve(for: ConfirmBillEmittersPaymentUseCase.self).setRequestValues(requestValues: input),
            useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
            onSuccess: { _ in
                completion(true, nil)
            },
            onError: { errorResult in
                switch errorResult {
                case .error(let signatureError):
                    self.handleSignatureError(for: presenter, signatureError: signatureError, completion: completion)
                default:
                    completion(false, nil)
                }
            }
        )
    }
    
    func setConfirmBillEmittersPaymentUseCaseInput() -> ConfirmBillEmittersPaymentUseCaseInput? {
        guard
            let account = self.operativeData.selectedAccount,
            let amount = self.operativeData.amount,
            let signature: SignatureRepresentable = self.container?.get(),
            let emitterCode = self.operativeData.selectedEmitter?.code,
            let productIdentifier = self.operativeData.selectedIncome?.productIdentifier,
            let collectionTypeCode = self.operativeData.selectedIncome?.typeCode,
            let collectionCode = self.operativeData.selectedIncome?.code
        else {
            return nil
        }
        return ConfirmBillEmittersPaymentUseCaseInput(
            account: account,
            signature: signature,
            amount: amount,
            emitterCode: emitterCode,
            productIdentifier: productIdentifier,
            collectionTypeCode: collectionTypeCode,
            collectionCode: collectionCode,
            billData: self.operativeData.fields.map { $0.value }
        )
    }
    
    func handleSignatureError(for presenter: SignaturePresentationDelegate, signatureError: GenericErrorSignatureErrorOutput?,
                              completion: (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let signatureError = signatureError else {
            completion(false, nil)
            return
        }
        switch signatureError.signatureResult {
        case .otherError:
            self.handleOtherError(for: presenter, signatureError: signatureError)
        default:
            completion(false, signatureError)
        }
    }
    
    func handleOtherError(for presenter: SignaturePresentationDelegate, signatureError: GenericErrorSignatureErrorOutput) {
        let operativesConfig: OperativeConfig? = self.container?.get()
        let phoneNumber = operativesConfig?.signatureSupportPhone
        presenter.dismissLoading {
            presenter.showDialog(
                description: localized(signatureError.getErrorDesc() ?? ""),
                phone: phoneNumber,
                action: Dialog.Action(title: localized("generic_button_accept"), action: {
                    self.container?.back(to: BillEmittersManualPaymentPresenter.self)
                }),
                isCloseOptionAvailable: false,
                stringLoader: self.dependencies.resolve(for: StringLoader.self)
            )
        }
    }
}

extension BillEmittersPaymentOperative: OperativeFinishingCoordinatorCapable {}

extension BillEmittersPaymentOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        return BillEmittersPaymentSignaturePage().page
    }
}

extension BillEmittersPaymentOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return dependencies.resolve(for: TrackerManager.self)
    }
    
    var extraParametersForTracker: [String: String] {
        return [
            TrackerDimension.billemitterPayment.key: ""
        ]
    }
}

extension BillEmittersPaymentOperative: OperativeSignatureNavigationCapable {
    var signatureNavigationTitle: String {
        return "toolbar_title_paymentOther"
    }
}

extension BillEmittersPaymentOperative: OperativeFaqsCapable {
    var infoHelpButtonFaqs: [FaqsItemViewModel]? {
        guard let container = self.container else { return nil }
        let parameter: BillEmittersPaymentOperativeData = container.get()
        let faqModel = parameter.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
            } ?? nil
        return faqModel
    }
}
