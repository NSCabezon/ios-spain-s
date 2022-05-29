import Foundation
import CoreFoundationLib

class ActivateSignOperative: Operative {
    let dependencies: PresentationComponent
    
    // MARK: - LifeCycle
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    var isShareable = true
    var needsReloadGP = false
    var steps: [OperativeStep] = []
    
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.personalAreaFinishedNavigator
    }
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        add(step: factory.createStep() as ActivateSignConfirmationOperativeStep)
        add(step: factory.createStep() as LisboaSignatureWithToken)
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let signatureFilled: SignatureFilled<SignatureWithToken> = container.provideParameter()
        let activateSignatureData: ActivateAndChangeSignatureOperativeData = container.provideParameter()
        let input = ConfirmSignatureActivationUseCaseInput(newSignature: activateSignatureData.newSignature, signatureToken: signatureFilled.signature)
        let usecase = dependencies.useCaseProvider.confirmSignatureActivationUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { [weak self] _ in
            self?.dependencies.trackerManager.trackEvent(screenId: TrackerPagePrivate.PersonalAreaActivateSignMultichannelSign().page, eventId: TrackerPagePrivate.PersonalAreaActivateSignMultichannelSign.Action.ok.rawValue, extraParameters: [:])
            completion(true, nil)
        }, onError: { [weak self] error in
            self?.container?.operative.trackErrorEvent(page: TrackerPagePrivate.PersonalAreaActivateMultichannelSign().page, error: error?.getErrorDesc(), code: error?.errorCode)
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return .empty
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        return nil
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    var numberOfStepsForProgress: Int {
        return 3
    }
    
    // MARK: - Tracker
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.PersonalAreaActivateSignMultichannelSign().page
    }
}

struct ActivateSignConfirmationOperativeStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.personalAreaOperatives.activateSignaturePresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
