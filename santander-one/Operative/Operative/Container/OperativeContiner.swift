import CoreFoundationLib
import UI
import UIKit
import IQKeyboardManagerSwift

private typealias Step = (presenter: OperativeStepPresenterProtocol, view: OperativeView, presentationType: OperativeStepPresentationType)

// - OperativeContainerProtocol

public protocol OperativeContainerProtocol: AnyObject {
    var handler: OperativeLauncherHandler? { get }
    var coordinator: OperativeContainerCoordinatorProtocol { get }
    var operative: Operative { get }
    func get<T>() -> T
    func getOptional<T>() -> T?
    func save<T>(_ parameter: T)
    func close()
    func goToFirstOperativeStep()
    func stepFinished(presenter: OperativeStepPresenterProtocol)
    func didSwipeBack()
    func progressBarAlpha(_ value: CGFloat)
    func back()
    func back<Presenter: OperativeStepPresenterProtocol>(to type: Presenter.Type)
    func back<Presenter: OperativeStepPresenterProtocol>(to type: Presenter.Type, creatingAt index: Int, step: OperativeStep)
    func go<Presenter: OperativeStepPresenterProtocol>(to type: Presenter.Type)
    func bringProgressBarToTop()
    func rebuildSteps()
    func trackFaqEvent(_ question: String, url: URL?)
    func showGenericError()
    func restoreProgressBar()
    func showGiveUpDialog()
    func dismissOperative()
    func getSubtitleInfo<Presenter: OperativeStepPresenterProtocol>(presenter: Presenter) -> String
    func getStepOfSteps<Presenter: OperativeStepPresenterProtocol>(presenter: Presenter) -> [Int]
    func currentStep() -> OperativeStepPresenterProtocol?
    func updateLastViewController()
    func clearParametersOfType<T>(type: T.Type)
}

// - OperativeContainerLauncher

enum OperativeContainerConstants {
    static let floatingButtonStepCorrectionFactor: Int = 2
}

public protocol OperativeContainerLauncher {
    func go(to operative: Operative, handler: OperativeLauncherHandler)
    func go<OperativeData>(to operative: Operative, handler: OperativeLauncherHandler, operativeData: OperativeData)
}

private extension OperativeContainerLauncher {
    func go(to operative: Operative, handler: OperativeLauncherHandler, willLoad: @escaping (OperativeContainer) -> Void) {
        guard let navigationController = handler.operativeNavigationController else { return }
        IQKeyboardManager.shared.enableAutoToolbar = false
        let container = OperativeContainer(
            operative: operative,
            handler: handler,
            coordinator: OperativeContainerCoordinator(
                navigationController: navigationController,
                dependenciesResolver: handler.dependenciesResolver
            )
        )
        willLoad(container)
        operative.container = container
        
        if let operativeJumpToStepCapable = operative as? OperativeJumpToStepCapable {
            container.goToOperative(step: operativeJumpToStepCapable.initialStep)
        } else {
            container.goToOperative()
        }
    }
}

public extension OperativeContainerLauncher {
    func go<OperativeData>(to operative: Operative, handler: OperativeLauncherHandler, operativeData: OperativeData) {
        self.go(to: operative, handler: handler, willLoad: { container in
            container.save(operativeData)
        })
    }
    
    func go(to operative: Operative, handler: OperativeLauncherHandler) {
        self.go(to: operative, handler: handler, willLoad: { _ in })
    }
}

// - Operative Container

public class OperativeContainer {
    public let operative: Operative
    public let coordinator: OperativeContainerCoordinatorProtocol
    public weak var handler: OperativeLauncherHandler?
    
    private weak var progressbar: LisboaProgressView?
    private var parameters: [Any]
    private let dependenciesResolver: DependenciesResolver
    
    init(operative: Operative, handler: OperativeLauncherHandler, coordinator: OperativeContainerCoordinatorProtocol) {
        self.operative = operative
        self.handler = handler
        self.coordinator = coordinator
        self.dependenciesResolver = handler.dependenciesResolver
        self.parameters = []
    }
    
    func goToOperative() {
        self.loadConfig {
            self.startOperative(step: 0)
        }
    }
    
    func goToOperative(step: Int) {
        self.loadConfig {
            self.startOperative(step: step)
        }
    }
    
    public func get<T>() -> T {
        guard
            let index = self.parameters.firstIndex(where: { $0 is T }),
            let parameter = self.parameters[index] as? T
        else {
            fatalError()
        }
        return parameter
    }
    
    public func getOptional<T>() -> T? {
        guard
            let index = self.parameters.firstIndex(where: { $0 is T }),
            let parameter = self.parameters[index] as? T
        else {
            return nil
        }
        return parameter
    }
    
    public func save<T>(_ parameter: T) {
        defer {
            self.parameters += [parameter]
        }
        guard let index = self.parameters.firstIndex(where: { $0 is T }) else { return }
        self.parameters.remove(at: index)
    }
    
    public func clearParametersOfType<T>(type: T.Type) {
        self.parameters.removeAll(where: { $0 is T })
    }
    
    public func close() {
        guard
            let operativeView = self.coordinator.navigationController?.viewControllers.last as? OperativeView,
            (operativeView.operativePresenter.number != operative.steps.count - 1 || operative.steps.count == 1)
        else {
            return self.finishOperative()
        }
        guard let operative = operative as? OperativeDialogFinishCapable else {
            self.showGiveUpDialog()
            return
        }
        operative.showPopUpDialog(operativeView.associatedViewController,
                                  acceptAction: openGiveUpOpinatorIfAvailable,
                                  cancelAction: restoreProgressBarIfAvailable)
    }
    
    public func showGiveUpDialog() {
        self.showOldDialog(
            title: localized("modal_title_stopOperation"),
            description: localized("modal_text_stopOperation"),
            acceptAction: DialogButtonComponents(titled: localized("modal_buton_goOut"), does: openGiveUpOpinatorIfAvailable),
            cancelAction: DialogButtonComponents(titled: localized("generic_button_cancel"), does: restoreProgressBarIfAvailable),
            isCloseOptionAvailable: true
        )
    }
    
    public func bringProgressBarToTop() {
        guard
            let navigationController = coordinator.navigationController,
            let progressView = progressbar
        else {
            addProgressbar()
            return
        }
        progressView.topAnchor.constraint(equalTo: navigationController.navigationBar.bottomAnchor, constant: 0).isActive = true
        navigationController.navigationBar.bringSubviewToFront(progressView)
    }
    
    private func restoreProgressBarIfAvailable() {
        guard
            let operativeView = self.coordinator.navigationController?.viewControllers.last as? OperativeView,
            operativeView.operativePresenter.shouldShowProgressBar
        else {
            return
        }
        self.addProgressbar()
        self.progressbar?.updateCurrent(current: operativeView.operativePresenter.number + self.stepsCorrectionFactor, animated: false)
        self.progressbar?.setTopBackgroundColor(operativeView.progressBarBackgroundColor)
    }
    
    private func openGiveUpOpinatorIfAvailable() {
        self.hideProgressbar()
        guard let giveUpOpinatorCapable = operative as? OperativeGiveUpOpinatorCapable else {
            return self.dismissOperative()
        }
        let opinator = giveUpOpinatorCapable.giveUpOpinator
        self.coordinator.handleGiveUpOpinator(opinator) { [weak self] in
            self?.dismissOperative()
        }
    }
    
    public func goToFirstOperativeStep() {
        guard
            let operativeViews = self.coordinator.navigationController?.viewControllers.filter({ $0 is OperativeView }),
            let indexInNavigation = self.coordinator.navigationController?.viewControllers.firstIndex(of: operativeViews[0]),
            let viewToPop = self.coordinator.navigationController?.viewControllers[indexInNavigation]
        else {
            self.coordinator.navigationController?.popToRootViewController(animated: true)
            self.hideProgressbar()
            return
        }
        self.progressbar?.updateCurrent(current: 0 + self.stepsCorrectionFactor, animated: false)
        self.coordinator.navigationController?.popToViewController(viewToPop, animated: true)
    }
    
    public func stepFinished(presenter: OperativeStepPresenterProtocol) {
        if presenter.number < operative.steps.count - 1 {
            showStep(at: presenter.number + 1)
        } else {
            finishOperative()
        }
    }
    
    public func didSwipeBack() {
        self.progressbar?.previousStep()
    }
    
    public func progressBarAlpha(_ value: CGFloat) {
        (coordinator.navigationController?.view.subviews
                    .filter({ $0 is LisboaProgressView }) ?? [])
                    .forEach({ $0.alpha = value })
    }
    
    public func back<Presenter: OperativeStepPresenterProtocol>(to type: Presenter.Type) {
        self.doBack(to: type)
    }
    
    public func back<Presenter: OperativeStepPresenterProtocol>(to type: Presenter.Type, creatingAt index: Int, step: OperativeStep) {
        // In case we couldn't go back (because the presenter type doesn't exist in the navigation stack)
        guard !self.doBack(to: type) else { return }
        guard
            let backToStepCapable = self.operative as? OperativeBackToStepCapable,
            // Filter all the viewcontrollers to only `OperativeView` type
            let operativeViews = self.coordinator.navigationController?.viewControllers.filter({ $0 is OperativeView }),
            // Get the resulting `OperativeView` array and get the view at `index`. Then, retrieve the index of that view in the navigation stack
            let indexInNavigation = self.coordinator.navigationController?.viewControllers.firstIndex(of: operativeViews[index]),
            // Then, get the view controller in the navigation stack at `indexInNavigation - 1`
            let viewToPop = self.coordinator.navigationController?.viewControllers[indexInNavigation - 1],
            let newOperativeStep = self.setupStep(step, at: index)
        else {
            return assertionFailure("The operative have to be OperativeBackToStepCapable")
        }
        self.create(newOperativeStep, operativeStep: step, at: index, viewToPop: viewToPop)
        backToStepCapable.stepAdded(step)
    }
    
    public func go<Presenter: OperativeStepPresenterProtocol>(to type: Presenter.Type) {
        guard let index = self.operative.steps.firstIndex(where: { $0.view?.operativePresenter is Presenter }) else { return }
        self.showStep(at: index)
    }
    
    public func rebuildSteps() {
        guard let rebuildStepsCapable = self.operative as? OperativeRebuildStepsCapable else { return }
        self.operative.steps = []
        rebuildStepsCapable.rebuildSteps()
        self.updateTotalSteps(self.progressbar)
    }
    
    public func dismissOperative() {
        self.hideProgressbar()
        if let operative = self.operative as? OperativeFinishingCoordinatorCapable {
            operative.finishingCoordinator.didFinishSuccessfully(self.coordinator, operative: self.operative)
        } else if let sourceView = self.coordinator.sourceView {
            self.coordinator.navigationController?.popToViewController(sourceView, animated: true)
        } else {
            self.coordinator.navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension OperativeContainer: OperativeContainerProtocol {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    public func trackFaqEvent(_ question: String, url: URL?) {
        let eventId = url == nil ? "click_show_faq" : "click_link_faq"
        var dic: [String: String] = ["faq_question": question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        trackerManager.trackEvent(screenId: "", eventId: eventId, extraParameters: dic)
    }
    
    public func showGenericError() {
        self.showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver,
                                    action: { [weak self] in
                                        self?.hideProgressbar()
                                    },
                                    closeAction: nil)
    }
    
    public func restoreProgressBar() {
        self.restoreProgressBarIfAvailable()
    }
    
    public func getSubtitleInfo<Presenter: OperativeStepPresenterProtocol>(presenter: Presenter) -> String {
        guard let index = self.operative.steps.firstIndex(where: { $0.view?.operativePresenter is Presenter }),
              index + 1 < operative.steps.count - 1
        else {
            return ""
        }
        let stepsVisited = self.operative.steps.prefix(index)
        let nextStepNumber = stepsVisited.filter({ $0.shouldCountForProgress }).count + OperativeContainerConstants.floatingButtonStepCorrectionFactor
        return localized(self.operative.steps[index + 1].floatingButtonTitleKey,
                         [StringPlaceholder(.number, "\(nextStepNumber)"),
                          StringPlaceholder(.number, "\(self.stepsForButton)")])
            .text
    }
    
    public func getStepOfSteps<Presenter: OperativeStepPresenterProtocol>(presenter: Presenter) -> [Int] {
        guard let index = self.operative.steps.firstIndex(where: { $0.view?.operativePresenter is Presenter }),
              index + 1 < operative.steps.count - 1
        else {
            return [0, self.stepsForButton]
        }
        let stepsVisited = self.operative.steps.prefix(index)
        let nextStepNumber = stepsVisited.filter({ $0.shouldCountForProgress }).count + OperativeContainerConstants.floatingButtonStepCorrectionFactor
        return [nextStepNumber, self.stepsForButton]
    }
    
    public func back() {
        defer {
            self.coordinator.navigationController?.popViewController(animated: true)
            let currentIndex = self.currentStep()?.number ?? .zero
            self.progressbar?.updateCurrent(current: currentIndex + self.stepsCorrectionFactor)
        }
        if self.coordinator.operativeViews.count <= 1 {
            self.hideProgressbar()
        } else if !self.coordinator.operativeViews[self.coordinator.operativeViews.count - 2].operativePresenter.shouldShowProgressBar {
            self.hideProgressbar()
        }
    }
    
    public func currentStep() -> OperativeStepPresenterProtocol? {
        let viewControllers = self.coordinator.navigationController?.viewControllers
        let current = viewControllers?.compactMap({ $0 as? OperativeView }).last?.operativePresenter
        return current
    }
    
    public func updateLastViewController() {
        let currentIndex = self.currentStep()?.number ?? .zero
        var viewControllers = self.coordinator.navigationController?.viewControllers.dropLast()
        let operativeStep = self.setupStep(self.operative.steps[currentIndex], at: currentIndex)
        viewControllers?.append(operativeStep?.view as? UIViewController ?? UIViewController())
        self.coordinator.navigationController?.viewControllers = Array(viewControllers ?? [])
    }
    
    public func showStep(at index: Int) {
        let step = self.operative.steps[index]
        guard let operativeStep = self.setupStep(step, at: index) else { return }
        let presenter = operativeStep.presenter
        let view = operativeStep.view
        if presenter.shouldShowProgressBar {
            self.addProgressbar()
        } else {
            self.hideProgressbar()
        }
        let showStepClousure = { [weak self] in
            self?.progressbar?.updateCurrent(current: presenter.number + (self?.stepsCorrectionFactor ?? .zero))
            switch step.presentationType {
            case .modal:
                self?.coordinator.presentModal(view)
            case .inNavigation(let showsBack, let showsCancel):
                presenter.isBackButtonEnabled = showsBack
                presenter.isCancelButtonEnabled = showsCancel
                self?.setupNavigation(for: view)
                self?.coordinator.push(view)
            }
        }
        if let stepEvaluator = step as? OperativeStepEvaluateCapable {
            stepEvaluator.evaluateBeforeShowing(container: self) { [weak self] result in
                switch result {
                case .show:
                    showStepClousure()
                case .showError(let error, onErrorAcceptAction: _):
                    self?.handler?.showOperativeAlertError(keyTitle: error?.title, keyDesc: error?.message) { [weak self] in
                        self?.goToFirstOperativeStep()
                    }
                case .skip:
                    self?.stepFinished(presenter: presenter)
                }
            }
        } else {
            showStepClousure()
        }
    }
}

private extension OperativeContainer {
    
    enum OperativeSetupType {
        case setup
        case preSetup
    }
    
    func create(_ step: Step, operativeStep: OperativeStep, at index: Int, viewToPop: UIViewController) {
        let presenter = step.view.operativePresenter
        switch step.presentationType {
        case.inNavigation(showsBack: let showsBack, showsCancel: let showsCancel):
            presenter.isBackButtonEnabled = showsBack
            presenter.isCancelButtonEnabled = showsCancel
        default:
            break
        }
        self.setupNavigation(for: step.view)
        self.operative.steps.insert(operativeStep, at: index)
        if presenter.shouldShowProgressBar {
            self.progressbar?.updateTotal(total: self.operative.steps.count - 1)
            self.progressbar?.updateCurrent(current: index + 1 + self.stepsCorrectionFactor)
        }
        // Pop to the OperativeView at `index` indicated
        self.coordinator.navigationController?.popToViewController(viewToPop, animated: false)
        // Then, push the new Operative View
        self.coordinator.navigationController?.blockingPushViewController(step.view.associatedViewController, animated: false) {
            Async.after(seconds: 0.2) { // Needed by a bug when you go back and create an step, the progress bar dissappear
                guard presenter.shouldShowProgressBar else {
                    self.hideProgressbar()
                    return
                }
                self.hideProgressbar()
                self.addProgressbar()
            }
        }
    }
    
    @discardableResult
    func doBack<Presenter: OperativeStepPresenterProtocol>(to type: Presenter.Type) -> Bool {
        guard
            let view = self.coordinator.navigationController?.viewControllers
                .last(where: { ($0 as? OperativeView)?.operativePresenter is Presenter })
                as? OperativeView
        else {
            return false
        }
        self.coordinator.navigationController?.popToViewController(view.associatedViewController, animated: true)
        if let showingViewController = self.coordinator.navigationController?.viewControllers
            .last(where: { $0 is OperativeView })
            as? OperativeView,
           !showingViewController.operativePresenter.shouldShowProgressBar {
            self.hideProgressbar()
        } else {
            self.progressbar?.updateCurrent(current: view.operativePresenter.number + self.stepsCorrectionFactor)
        }
        return true
    }
    
    func finishOperative() {
        guard let operative = self.operative as? OperativeGlobalPositionReloaderCapable else {
            return operativeDidFinish()
        }
        self.dependenciesResolver.resolve(for: GlobalPositionReloadEngine.self).add(self)
        operative.reloadGlobalPosition()
    }
    
    func operativeDidFinish() {
        let finishingCapable = self.operative as? OperativeFinishingCapable
        finishingCapable?.operativeDidFinish()
        self.dismissOperative()
    }
    
    func loadConfig(_ completion: @escaping () -> Void) {
        MainThreadUseCaseWrapper(
            with: OperativeSetupUseCase(dependenciesResolver: self.dependenciesResolver),
            onSuccess: { result in
                self.save(result.config)
                completion()
            }
        )
    }
    
    func startOperative(step: Int) {
        let setupProcess: [OperativeSetupType] = [.preSetup, .setup]
        self.handler?.showOperativeLoading {
            self.setupProcess(
                with: setupProcess,
                onSuccess: {
                    self.handler?.hideOperativeLoading {
                        self.createPreviousStepsIfNeeded(at: step)
                        self.showStep(at: step)
                    }
                },
                onError: { error in
                    self.handler?.hideOperativeLoading {
                        self.handler?.showOperativeAlertError(keyTitle: error.title, keyDesc: error.message, completion: nil)
                    }
                }
            )
        }
    }
    
    func setupProcess(with process: [OperativeSetupType], onSuccess: @escaping () -> Void, onError: @escaping (OperativeSetupError) -> Void) {
        guard process.count > 0 else { return onSuccess() }
        switch process[0] {
        case .preSetup:
            self.performPreSetup(
                onSuccess: {
                    self.setupProcess(with: Array(process.dropFirst()), onSuccess: onSuccess, onError: onError)
                },
                onError: onError
            )
        case .setup:
            self.performSetup(
                onSuccess: {
                    self.setupProcess(with: Array(process.dropFirst()), onSuccess: onSuccess, onError: onError)
                },
                onError: onError
            )
        }
    }
    
    func performPreSetup(onSuccess: @escaping () -> Void, onError: @escaping (OperativeSetupError) -> Void) {
        guard let operative = self.operative as? OperativePresetupCapable else { return onSuccess() }
        operative.performPreSetup(
            success: onSuccess,
            failed: onError
        )
    }
    
    func performSetup(onSuccess: @escaping () -> Void, onError: @escaping (OperativeSetupError) -> Void) {
        guard let operative = self.operative as? OperativeSetupCapable else { return onSuccess() }
        operative.performSetup(
            success: onSuccess,
            failed: onError
        )
    }
    
    func createPreviousStepsIfNeeded(at index: Int) {
        let sequence = stride(from: 0, through: index - 1, by: 1)
        sequence.forEach { step in
            createStepInNavigation(at: step)
        }
    }
    
    func createStepInNavigation(at index: Int) {
        let step = self.operative.steps[index]
        guard let view = step.view else { return }
        let presenter = view.operativePresenter
        presenter.container = self
        presenter.number = index
        switch step.presentationType {
        case .modal: break
        case .inNavigation(let showsBack, let showsCancel):
            presenter.isBackButtonEnabled = showsBack
            presenter.isCancelButtonEnabled = showsCancel
            self.setupNavigation(for: view)
            self.coordinator.append(view)
        }
    }
    
    func setupStep(_ step: OperativeStep, at index: Int) -> Step? {
        guard let view = step.view else { return nil }
        let presenter = view.operativePresenter
        presenter.container = self
        presenter.number = index
        self.setupNavigation(for: view)
        return (presenter, view, step.presentationType)
    }
    
    func setupNavigation(for view: OperativeView) {
        if view.operativePresenter.isBackButtonEnabled {
            let leftBarButton = UIBarButtonItem(image: Assets.image(named: "icnReturnRed")?.withRenderingMode(.alwaysTemplate),
                                                style: .plain,
                                                target: self,
                                                action: #selector(dismissViewController))
            leftBarButton.tintColor = .santanderRed
            leftBarButton.accessibilityIdentifier = "icnReturnRed"
            leftBarButton.accessibilityLabel = localized("siri_voiceover_back")
            view.associatedViewController.navigationItem.leftBarButtonItem = leftBarButton
        } else {
            view.associatedViewController.navigationItem.hidesBackButton = true
            view.associatedViewController.navigationItem.leftBarButtonItem = nil
        }
        if view.operativePresenter.isCancelButtonEnabled {
            let rightBarButton = UIBarButtonItem(image: Assets.image(named: "icnClose")?.withRenderingMode(.alwaysTemplate),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(closeOperative))
            rightBarButton.tintColor = .santanderRed
            rightBarButton.accessibilityIdentifier = AccessibilityOperative.btcClose
            view.associatedViewController.navigationItem.rightBarButtonItem = rightBarButton
        } else {
            view.associatedViewController.navigationItem.rightBarButtonItem = nil
        }
        self.progressbar?.setTopBackgroundColor(view.progressBarBackgroundColor)
    }
    
    @objc func dismissViewController() {
        back()
    }
    
    @objc func closeOperative() {
        self.close()
    }
    
    func hideProgressbar() {
        self.progressbar?.removeFromSuperview()
        (coordinator.navigationController?.view.subviews
            .filter({ $0 is LisboaProgressView }) ?? [])
            .forEach({ $0.removeFromSuperview() })
        self.progressbar = nil
    }
    
    func addProgressbar() {
        guard self.progressbar == nil else {
            return
        }
        guard let navigationController = coordinator.navigationController else {
            return
        }
        let progressView = LisboaProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressBarType = operative.progressBarType
        self.progressbar = progressView
        navigationController.view.insertSubview(progressView, belowSubview: navigationController.navigationBar)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: navigationController.navigationBar.bottomAnchor, constant: 0),
            progressView.leftAnchor.constraint(equalTo: navigationController.view.leftAnchor, constant: 0),
            progressView.rightAnchor.constraint(equalTo: navigationController.view.rightAnchor, constant: 0)
        ])
        progressView.configure(background: UIColor.lightSanGray, fill: UIColor.bostonRed)
        self.updateTotalSteps(progressView)
    }
    
    func updateTotalSteps(_ progressView: LisboaProgressView?) {
        guard let operativeCapable = self.operative as? OperativeProgressBarCapable else {
            progressView?.updateTotal(total: self.operative.steps.count - 1)
            return
        }
        progressView?.updateTotal(total: operativeCapable.customStepsNumber)
    }
    
    var stepsCorrectionFactor: Int {
        guard let operativeCapable = self.operative as? OperativeProgressBarCapable else {
            return .zero
        }
        return operativeCapable.stepsCorrectionFactor
    }
    
    var stepsForProgress: Int {
        return self.operative.steps.filter({ $0.shouldCountForProgress }).count
    }
    
    var stepsForButton: Int {
        return self.operative.steps.filter({ $0.shouldCountForContinueButton }).count
    }
}

extension OperativeContainer: OldDialogViewPresentationCapable {
    
    public var associatedOldDialogView: UIViewController {
        return UIApplication.topViewController() ?? UIViewController()
    }
    public var associatedGenericErrorDialogView: UIViewController {
        let lastViewController = self.coordinator.navigationController?.viewControllers.last
        return lastViewController ?? UIViewController()
    }
}

extension OperativeContainer: GenericErrorDialogPresentationCapable { }

extension OperativeContainer: GlobalPositionReloadable {
    
    public func reload() {
        self.operativeDidFinish()
    }
}
