import CoreFoundationLib
import Transfer

protocol StopOperativeProtocol {
    func onSuccess(container: OperativeContainerProtocol)
    func onSignatureError(container: OperativeContainerProtocol)
    func onCancelByUser(container: OperativeContainerProtocol)
    func resetOperative(container: OperativeContainerProtocol)
}

extension StopOperativeProtocol {
    func onSuccess(container: OperativeContainerProtocol) {
        let sourceView = container.operativeContainerNavigator.sourceView
        if let productHome = sourceView as? ProductHomeViewController {
            sourceView?.navigationController?.popToViewController(productHome, animated: true)
        } else if let transferHome = sourceView as? TransferHomeViewController {
            sourceView?.navigationController?.popToViewController(transferHome, animated: true)
        } else {
            // reset to Global Position
            sourceView?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func onSignatureError(container: OperativeContainerProtocol) {
        if let firstViewController = container.operativeContainerNavigator.firstViewController {
            if firstViewController is GenericSignatureViewController {
                onCancelByUser(container: container)
            } else {
                container.operativeContainerNavigator.sourceView?.navigationController?.popToViewController(firstViewController, animated: true)
            }
        }
    }
    
    func onCancelByUser(container: OperativeContainerProtocol) {
        guard let sourceView = container.operativeContainerNavigator.sourceView else {
            return
        }
        sourceView.navigationController?.popToViewController(sourceView, animated: true)
    }
    
    func resetOperative(container: OperativeContainerProtocol) {
        if let sourceView = container.operativeContainerNavigator.sourceView, let navCont = sourceView.navigationController, let sourceIndex = navCont.viewControllers.firstIndex(of: sourceView), sourceIndex+1 < navCont.viewControllers.count {
            navCont.popToViewController(navCont.viewControllers[sourceIndex+1], animated: true)
        }
    }
}

enum OperativeSummaryState {
    case success
    case error
    case pending
}

public enum OperativeSharingType {
    case text
    case image
}

typealias ErrorOperativePreSetup = (title: String?, message: String?)

protocol Operative: class, ContainerCollector, OperativeProgress {
    var dependencies: PresentationComponent { get }
    var isShareable: Bool { get }
    var needsReloadGP: Bool { get }
    var steps: [OperativeStep] { get set }
    var finishedOperativeNavigator: StopOperativeProtocol { get }
    var container: OperativeContainerProtocol? { get set }
    var opinatorPage: OpinatorPage? { get }
    var giveUpOpinatorPage: OpinatorPage? { get }
    var signatureTitle: LocalizedStylableText { get }
    var screenIdSignature: String? { get }
    var screenIdOtp: String? { get }
    var screenIdSummary: String? { get }
    var screenIdProductSelection: String? { get }
    var extraParametersForTrackerError: [String: String]? { get }
    var pdfContent: String? { get }
    var pdfTitle: String? { get }
    var pdfSource: PdfSource { get }
    var signatureNavigationTitle: String? { get }
    var otpNavigationTitle: String? { get }
    var infoHelpButtonFaqs: [FaqsItemViewModel]? { get }
    var sharingType: OperativeSharingType { get }
    func getTrackParametersSummary() -> [String: String]?
    func getExtraTrackShareParametersSummary() -> [String: String]?
    func getTrackParametersSignature() -> [String: String]?
    func getTrackParametersOTP() -> [String: String]?
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void)
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void)
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void)
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void)
    func operativeDidFinish()
    func getSummaryTitle() -> LocalizedStylableText
    func getSummarySubtitle() -> LocalizedStylableText?
    func getSummaryInfo() -> [SummaryItemData]?
    func getAdditionalMessage() -> LocalizedStylableText?
    func getSummaryContinueButtonText() -> LocalizedStylableText?
    func getSummaryState() -> OperativeSummaryState
    func trackErrorEvent(page: String?, error: String?, code: String?)
    func rebuildSteps()
    func getRichSharingText() -> String?
    func getSummaryImage() -> ShareTransferSummaryView?
}

enum MifidState {
    case unknown
    case launched(OperativeStepPresenterProtocol)
    case finishing(steps: Int) // Define a state where the mifid container is finishing but it is not finish yet
    case finished(steps: Int)
}

protocol MifidLauncherOperative: Operative {
    var mifidState: MifidState { get set }
}

protocol MifidLauncherPresenterProtocol: OperativeStepPresenterProtocol, MifidContainerDelegate {}

extension MifidLauncherPresenterProtocol {
    var operative: MifidLauncherOperative? {
        return container?.operative as? MifidLauncherOperative
    }
    
    func mifidDidFinish() {
        switch operative?.mifidState {
        case .finishing(steps: let steps)?: operative?.mifidState = .finished(steps: steps)
        default: break
        }
        container?.stepFinished(presenter: self)
    }
    
    func mifidWillFinish(steps: Int) {
        operative?.mifidWillFinish(steps: steps)
    }
}

extension MifidLauncherOperative {
    
    var numberOfStepsForProgress: Int {
        return self.steps.count - 1
    }
    
    func mifidLaunched(from presenterLauncher: OperativeStepPresenterProtocol) {
        mifidState = .launched(presenterLauncher)
    }
    
    func mifidWillFinish(steps: Int) {
        mifidState = .finishing(steps: steps)
    }
    
    func updateProgress(of presenter: OperativeStepProgressProtocol) {
        guard shouldShowProgress else {
            return
        }
        var currentPresenterIndex = presenter.number
        switch mifidState {
        // if mifid is launched and the presenter is a MifidPresenter
        case .launched(let presenterLauncher) where presenter is MifidPresenterProtocol:
            let presenterLauncherNumber = presenterLauncher.number
            currentPresenterIndex = presenter.number - 1
            container?.updateProgress(totalUnitCount: Int64(numberOfStepsForProgress + currentPresenterIndex), completedUnitCount: Int64(presenterLauncherNumber + currentPresenterIndex))
        // if mifid did finish and the presenter is the MifidLauncher (we go back once we have finished the mifid)
        case .finished where presenter is MifidLauncherPresenterProtocol:
            mifidState = .unknown
            container?.updateProgress(totalUnitCount: Int64(numberOfStepsForProgress), completedUnitCount: Int64(currentPresenterIndex))
        // if mifid did finish (get the mifid steps in order to add it to the number of steps)
        case .finished(steps: let steps):
            container?.updateProgress(totalUnitCount: Int64(numberOfStepsForProgress + steps), completedUnitCount: Int64(currentPresenterIndex + steps))
        // if mifid is finishing (nothing to do)
        case .finishing:
            break
        default:
            container?.updateProgress(totalUnitCount: Int64(numberOfStepsForProgress), completedUnitCount: Int64(currentPresenterIndex))
        }
    }
}

protocol OperativeProgress {
    var shouldShowProgress: Bool { get }
    var numberOfStepsForProgress: Int { get }
    func updateProgress(of presenter: OperativeStepProgressProtocol)
}

extension Operative {
    var pdfContent: String? {
        return nil
    }
    var pdfTitle: String? {
        return nil
    }
    var numberOfStepsForProgress: Int {
        return steps.count
    }
    var shouldShowProgress: Bool {
        return true
    }
    
    var pdfSource: PdfSource {
       return .summary
    }
    
    var signatureNavigationTitle: String? {
        return nil
    }
    var otpNavigationTitle: String? {
        return nil
    }
    var infoHelpButtonFaqs: [FaqsItemViewModel]? {
        nil
    }
    
    var sharingType: OperativeSharingType {
        return .text
    }
    
    func updateProgress(of presenter: OperativeStepProgressProtocol) {
        guard shouldShowProgress else {
            return
        }
        container?.updateProgress(totalUnitCount: Int64(numberOfStepsForProgress - 1), completedUnitCount: Int64(presenter.number))
    }
}

extension Operative {
    var screenIdSignature: String? {
        return nil
    }
    var screenIdSummary: String? {
        return nil
    }
    var screenIdOtp: String? {
        return nil
    }
    var screenIdProductSelection: String? {
        return nil
    }
    var extraParametersForTrackerError: [String: String]? {
        return nil
    }
    
    var signatureTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_signing")
    }
    
    func trackErrorEvent(page: String?, error: String?, code: String?) {
        guard let page = page else { return }
        var parmaters: [String: String] = extraParametersForTrackerError ?? [:]
        if let errorDesc = error {
            parmaters[TrackerDimensions.descError] = errorDesc
        }
        if let errorCode = code {
            parmaters[TrackerDimensions.codError] = errorCode
        }
        self.dependencies.trackerManager.trackEvent(screenId: page, eventId: TrackerPagePrivate.Generic.Action.error.rawValue, extraParameters: parmaters)
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        return nil
    }
    
    func getExtraTrackShareParametersSummary() -> [String: String]? {
        return nil
    }
    
    func getTrackParametersSignature() -> [String: String]? {
        return nil
    }
    
    func getTrackParametersOTP() -> [String: String]? {
        return nil
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        success()
    }
    
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        completion(true, nil)
    }
    
    func start(needsSelection: Bool? = nil, container: OperativeContainerProtocol, delegate: OperativeLauncherPresentationDelegate) {
        delegate.startOperativeLoading { [weak self] in
            self?.performPreSetup(for: delegate, container: container, completion: { [weak self] (result, error) in
                if result {
                    if needsSelection == true {
                        delegate.hideOperativeLoading {
                            container.start()
                        }
                    } else {
                        self?.performSetup(for: delegate, container: container, success: {
                            delegate.hideOperativeLoading {
                                container.start()
                            }
                        })
                    }
                } else {
                    delegate.hideOperativeLoading {
                        if let error = error {
                            delegate.showOperativeAlertError(keyTitle: error.title, keyDesc: error.message, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    var opinatorPage: OpinatorPage? {
        return nil
    }
    
    var giveUpOpinatorPage: OpinatorPage? {
        return opinatorPage
    }

    func add(step: OperativeStep) {
        var step = step
        step.number = steps.count
        steps.append(step)
    }
    
    func addProductSelectionStep<Product: GenericProduct>(of productType: Product.Type) {
        let parameter: ProductSelection<Product> = containerParameter()
        if let presenterProvider = container?.presenterProvider, !parameter.isProductSelectedWhenCreated {
            let factory = OperativeStepFactory(presenterProvider: presenterProvider)
            add(step: factory.createStep() as ProductSelectionStep<DefaultOperativeProductSelectionProfile<Product>>)
        }
    }
    
    func getSummaryState() -> OperativeSummaryState {
        return .success
    }
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {}
    
    func operativeDidFinish() {}
    
    func resetSteps() {
        steps.removeAll()
    }
    
    func rebuildSteps() {
    }
    
    func getRichSharingText() -> String? {
        return nil
    }
    
    func getSummaryImage() -> ShareTransferSummaryView? {
        return nil
    }
}
