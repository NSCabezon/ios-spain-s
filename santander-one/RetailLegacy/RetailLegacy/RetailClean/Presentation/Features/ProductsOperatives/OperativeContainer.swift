import CoreFoundationLib
import UI

struct OperativeContainerDialog {
    static var empty: OperativeContainerDialog {
        return OperativeContainerDialog(titleKey: nil, descriptionKey: nil, acceptAction: nil)
    }
    var titleKey: String?
    var descriptionKey: String?
    var acceptAction: (() -> Void)?
}

protocol GlobalPositionConditionedPresenter {}
protocol UpdateAliasConditionedPresenter {}

protocol OperativeContainerProtocol: OperativeContainerProgressProtocol {
    var operative: Operative { get set }
    var operativeContainerNavigator: OperativeContainerNavigatorProtocol { get }
    var presenterProvider: PresenterProvider { get set }
    var currentPresenter: OperativeStepPresenterProtocol? { get set }
    var needsOTP: Bool { get }
    func start()
    func onSignatureError()
    func stepFinished(presenter: OperativeStepPresenterProtocol)
    func provideParameter<P>() -> P
    func provideParameterOptional<P>() -> P?
    func saveParameter<P>(parameter: P)
    func cancelTouched(completion: (() -> Void)?)
    func reloadPG(onSuccess completion: (() -> Void)?, onError completionError: ((String?) -> Void)?)
    func reloadPGAndExit()
    func rebuildSteps()
    func backModify<ViewController: UIViewController>(controller: ViewController.Type)
    func enablePopGestureRecognizer(_ enable: Bool)
}

protocol OperativeContainerProgressProtocol: class {
    func updateProgress(totalUnitCount: Int64, completedUnitCount: Int64)
}

protocol ContainerCollector {
    var container: OperativeContainerProtocol? { get }
    func containerParameter<T>() -> T
}

extension ContainerCollector {
    func containerParameter<T>() -> T {
        guard let container = container else {
            fatalError()
        }
        return container.provideParameter()
    }
}

class OperativeContainer: OperativeContainerProtocol {
    var operative: Operative
    var repository: [Any]
    var dependencies: PresentationComponent
    var presenterProvider: PresenterProvider
    var needsOTP: Bool {
        return operative.steps.contains(where: { (step) in
            return step is OperativeOTP
        })
    }
    weak var currentPresenter: OperativeStepPresenterProtocol?
    var progress: Progress? {
        didSet {
            operativeContainerNavigator.navigationController?.setProgress(progress)
        }
    }
    var operativeContainerNavigator: OperativeContainerNavigatorProtocol
    private lazy var sessionDataManager: SessionDataManager = {
        let manager = DefaultSessionDataManager(dependenciesResolver: dependencies.dependenciesEngine)
        manager.setDataManagerProcessDelegate(sessionProcessHelperDelegate)
        return manager
    }()
    private lazy var sessionProcessHelperDelegate: ReloadSessionDelegate = {
        return ReloadSessionDelegate(stringLoader: dependencies.stringLoader,
                                     globalPositionReloadEngine: dependencies.globalPositionReloadEngine)
    }()
    
    init(operative: Operative,
         repository: [OperativeParameter],
         dependencies: PresentationComponent,
         presenterProvider: PresenterProvider,
         operativeContainerNavigator: OperativeContainerNavigatorProtocol) {
        self.operative = operative
        self.repository = repository
        self.dependencies = dependencies
        self.presenterProvider = presenterProvider
        self.operativeContainerNavigator = operativeContainerNavigator
        if operative.shouldShowProgress {
            self.progress = Progress(totalUnitCount: 0)
            operativeContainerNavigator.navigationController?.setProgress(progress)
        }
        self.operativeContainerNavigator.operativeContainer = self
    }
    
    func start() {
        operative.container = self
        guard self.operative.steps.count > 0 else {
            self.operativeDidFinish()
            return
        }
        presentStep(atIndex: 0)
    }
    
    func stepFinished(presenter: OperativeStepPresenterProtocol) {
        if presenter.number < operative.steps.count - 1 {
            presentStep(atIndex: presenter.number + 1)
        } else {
            finishOperative()
        }
    }
    
    func provideParameterOptional<P>() -> P? {
        guard let found = (repository.first { $0 is P }) as? P else {
            return nil
        }
        return found
    }
    
    func provideParameter<P>() -> P {
        guard let found = (repository.first { $0 is P }) as? P else {
            fatalError()
        }
        return found
    }
    
    func saveParameter<P>(parameter: P) {
        if let index = (repository.firstIndex { $0 is P }) {
            repository[index] = parameter
        } else {
            repository += [parameter]
        }
    }
    
    private func presentStep(atIndex index: Int) {
        let step = operative.steps[index]
        let presenter = step.presenter
        presenter.container = self
        presenter.number = index
        presenter.evaluateBeforeShowing(onSuccess: { [weak self] result in
            guard let thisContainer = self else {
                return
            }
            guard result else {
                thisContainer.stepFinished(presenter: presenter)
                return
            }
            switch step.presentationType {
            case .modal:
                self?.operativeContainerNavigator.presentModal(presenter)
            case .inNavigation:
                presenter.showsBackButton = step.showsBack
                presenter.showsCancelButton = step.showsCancel
                self?.operativeContainerNavigator.push(presenter)
            }
        }, onError: { [weak self] dialog in
            guard let thisContainer = self else {
                return
            }
            thisContainer.show(dialog: dialog)
        })
    }
    
    private func finishOperative() {
        if operative.needsReloadGP {
            reloadPGAndExit()
        } else {
            operativeDidFinish()
        }
    }
    
    func reloadPGAndExit() {
        let completion: () -> Void = { [weak self] in
            self?.presenterProvider.sessionManager.sessionStarted(completion: {
                self?.operativeDidFinish()
            })
        }
        let completionError: (String?) -> Void = { [weak self] error in
            self?.presenterProvider.sessionManager.finishWithReason(.failedGPReload(reason: error))
        }
        reloadPG(onSuccess: completion, onError: completionError)
    }
    
    func reloadPG(onSuccess completion: (() -> Void)?, onError completionError: ((String?) -> Void)?) {
        let stringLoader = dependencies.stringLoader
        let loadingText = LoadingText(title: stringLoader.getString("generic_popup_loading"), subtitle: stringLoader.getString("loading_label_moment"))
        LoadingCreator.showGlobalLoading(loadingText: loadingText,
                                         controller: operativeContainerNavigator.navigationController) { [weak self] in
            self?.sessionProcessHelperDelegate.onSuccess = completion
            self?.sessionProcessHelperDelegate.onError = completionError
            self?.sessionProcessHelperDelegate.view = self?.operativeContainerNavigator.currentViewController
            self?.loadSessionData()
        }
    }
    
    private func operativeDidFinish() {
        operative.operativeDidFinish()
        operative.finishedOperativeNavigator.onSuccess(container: self)
    }
    
    func cancelTouched(completion: (() -> Void)? = nil) {
        func cancelOperative() {
            operative.finishedOperativeNavigator.onCancelByUser(container: self)
        }
        self.operativeContainerNavigator.currentViewController?.disableEditing(force: false)
        let stringLoader = dependencies.stringLoader
        let dialogButtonsFont = UIFont.santander(family: .text, type: .regular, size: 16)
        ResumePopupView.presentPopup(title: stringLoader.getString("modal_title_stopOperation"),
                                     description: stringLoader.getString("modal_text_stopOperation"),
                                     confirmTitle: stringLoader.getString("modal_button_yesGoOut"),
                                     cancelTitle: stringLoader.getString("modal_alert_button_noWantContinue"),
                                     font: dialogButtonsFont, hideCheckView: true) { [weak self] (confirmed, _) in
                                        guard confirmed else { return }
                                        if let giveUpOpinatorPage = self?.operative.giveUpOpinatorPage {
                                            self?.openOpinator(forGiveUpPage: giveUpOpinatorPage, backAction: .nothing, onCompletion: { _ in
                                                cancelOperative()
                                            }, onError: { _ in
                                                cancelOperative()
                                            })
                                        } else {
                                            cancelOperative()
                                        }
                                    }
    }
    
    func onSignatureError() {
        operative.finishedOperativeNavigator.onSignatureError(container: self)
    }
    
    func rebuildSteps() {
        operative.resetSteps()
        operative.rebuildSteps()
    }
    
    // MARK: - OperativeContainerProgressProtocol
    
    func updateProgress(totalUnitCount: Int64, completedUnitCount: Int64) {
        let progress = self.progress ?? Progress(totalUnitCount: totalUnitCount)
        progress.totalUnitCount = totalUnitCount
        if #available(iOS 10, *) {
            progress.completedUnitCount = completedUnitCount
        } else {
            // This fix should only be available on iOS 9.
            // The completedUnitCount setter on iOS 9 blocked the main thread, freezing the app.
            // Moving the action to other thread allows the operative to continue working.
            DispatchQueue.global().async {
                progress.completedUnitCount = completedUnitCount
            }
        }
    }
    
    func backModify<ViewController: UIViewController>(controller: ViewController.Type) {
        let sourceView = self.operativeContainerNavigator.sourceView
        guard
            let viewController = sourceView?.navigationController?.viewControllers.reversed().first(where: { $0 is ViewController })
        else { return }
        sourceView?.navigationController?.popToViewController(viewController, animated: false)
    }
    
    func enablePopGestureRecognizer(_ enable: Bool) {
        operativeContainerNavigator.currentViewController?.enablePopGestureRecognizer(enable)
    }
    
    private func loadSessionData() {
        self.sessionDataManager.load()
    }
}

extension OperativeContainer {
    private func show(dialog: OperativeContainerDialog) {
        guard let current = operativeContainerNavigator.currentViewController else {
            return
        }
        let stringLoader = dependencies.stringLoader
        let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: dialog.acceptAction)
        guard let error = dialog.descriptionKey else {
            return self.showGenericErrorDialog(withDependenciesResolver: dependencies.navigatorProvider.dependenciesEngine)
        }
        let errorMsg: LocalizedStylableText = LocalizedStylableText(text: error, styles: nil)
        Dialog.alert(title: stringLoader.getString(dialog.titleKey ?? ""), body: errorMsg,
                     withAcceptComponent: accept, withCancelComponent: nil, source: current, shouldTriggerHaptic: true)
    }
}

extension OperativeContainer: BaseWebViewNavigatable {
    var drawer: BaseMenuViewController {
        return dependencies.navigatorProvider.drawer
    }
}

extension OperativeContainer: OpinatorLauncher {
    var genericErrorHandler: GenericPresenterErrorHandler {
        guard let currentPresenter = currentPresenter else {
            fatalError()
        }
        return currentPresenter.genericErrorHandler
    }
    
    var baseWebViewNavigatable: BaseWebViewNavigatable {
        return self
    }
}

extension OperativeContainer: GenericErrorDialogPresentationCapable {
    var associatedGenericErrorDialogView: UIViewController {
        return self.operativeContainerNavigator.currentViewController ?? UIViewController()
    }
}
