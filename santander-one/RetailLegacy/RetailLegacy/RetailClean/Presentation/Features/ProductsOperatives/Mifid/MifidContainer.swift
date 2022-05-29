import UIKit

protocol MifidContainerProtocol: class {
    var mifidOperative: MifidOperative { get }
    var delegate: MifidContainerDelegate? { get }
    var sourceView: UIViewController { get }
    var presenterProvider: PresenterProvider { get }
    func start()
    func showCommonLoading(completion: @escaping () -> Void)
    func hideCommonLoading(completion: @escaping () -> Void)
    func mifidStepFinished(presenter: MifidPresenterProtocol)
    func provideParameter<P: OperativeParameter>() -> P
    func saveParameter<P: OperativeParameter>(parameter: P)
    func cancelMifid()
    func cancelOperativeTouched()
}

protocol MifidContainerDelegate: class {
    func performValidate(for mifidContainer: MifidContainerProtocol, onSuccess: @escaping () -> Void)
    func mifidDidFinish()
    func mifidWillFinish(steps: Int)
    func mifidWillShow(_ presenter: MifidPresenterProtocol)
}

extension MifidContainerDelegate where Self: OperativeStepPresenterProtocol {
    
    func mifidWillShow(_ presenter: MifidPresenterProtocol) {
        if presenter.shouldShowProgress {
            container?.operative.updateProgress(of: presenter)
        }
    }
}

class MifidContainer {
    private enum ContainerState {
        case loading
        case ready
    }
    let mifidOperative: MifidOperative
    let sourceView: UIViewController
    let presenterProvider: PresenterProvider
    private weak var operativeContainer: OperativeContainerProtocol?
    private weak var lastModalPresented: MifidPresenterProtocol?
    private var containerState: ContainerState = .ready
    private var commonLoading: LoadingActionProtocol?
    weak var delegate: MifidContainerDelegate?
    private let stringLoader: StringLoader
    fileprivate var stepsPresentedInNavigation: Int = 0
    
    init(mifidOperative: MifidOperative, operativeContainer: OperativeContainerProtocol, delegate: MifidContainerDelegate, sourceView: UIViewController, presenterProvider: PresenterProvider, stringLoader: StringLoader) {
        self.mifidOperative = mifidOperative
        self.delegate = delegate
        self.sourceView = sourceView
        self.presenterProvider = presenterProvider
        self.operativeContainer = operativeContainer
        self.stringLoader = stringLoader
    }
}

extension MifidContainer: MifidContainerProtocol {
    func start() {
        guard let first = MifidStep(rawValue: 0) else {
            return
        }
        present(step: first)
    }
    
    func mifidStepFinished(presenter: MifidPresenterProtocol) {
        dismissAnyModal { [weak self] in
            guard let next = MifidStep(rawValue: presenter.mifidStep.rawValue + 1) else {
                self?.finishMifid()
                return
            }
            self?.present(step: next)
        }
    }
    
    func showCommonLoading(completion: @escaping () -> Void) {
        guard containerState != .loading else {
            completion()
            return
        }
        let loadingType = LoadingViewType.onDrawer(completion: completion, shakeDelegate: nil)
        let text = LoadingText(title: stringLoader.getString("generic_popup_loading"), subtitle: stringLoader.getString("loading_label_moment"))
        commonLoading = LoadingCreator.createAndShowLoading(info: LoadingInfo(type: loadingType, loadingText: text, placeholders: nil, topInset: nil))
        containerState = .loading
    }
    
    func hideCommonLoading(completion: @escaping () -> Void) {
        commonLoading?.hideLoading(completion: completion)
        commonLoading = nil
        containerState = .ready
    }
    
    private func present(step: MifidStep) {
        let presenter = step.presenter(forOperative: mifidOperative, withProvider: presenterProvider)
        presenter?.container = self
        presenter?.evaluateBeforeShowing(onSuccess: { [weak self] show in
            if show {
                guard let presenter = presenter else {
                    return
                }
                self?.performPresententation(of: presenter)
            } else {
                DispatchQueue.main.async {
                    self?.mifidStepFinished(presenter: presenter!)
                }
            }
        })
    }
    
    private func performPresententation(of presenter: MifidPresenterProtocol) {
        guard let presenterView = presenter.stepView as? UIViewController else {
            return
        }
        switch presenter.mifidStep.presentation {
        case .modal:
            presenterView.modalTransitionStyle = .coverVertical
            presenterView.modalPresentationStyle = .overCurrentContext
            sourceView.present(presenterView, animated: true, completion: nil)
            lastModalPresented = presenter
        case .inNavigation:
            guard stepsPresentedInNavigation > 0 else {
                stepsPresentedInNavigation += 1
                sourceView.navigationController?.pushViewController(presenterView, animated: true)
                return
            }
            
            if var actualViewsStack = sourceView.navigationController?.viewControllers.dropLast() {
                actualViewsStack.append(presenterView)
                stepsPresentedInNavigation += 1
                sourceView.navigationController?.setViewControllers(Array(actualViewsStack), animated: true)
            } else {
                sourceView.navigationController?.popViewController(animated: false)
                stepsPresentedInNavigation += 1
                sourceView.navigationController?.pushViewController(presenterView, animated: true)
            }
        }
    }
    
    private func finishMifid() {
        showCommonLoading { [weak self] in
            self?.delegate?.mifidWillFinish(steps: self?.stepsPresentedInNavigation ?? 0)
            self?.resetMifidNavigation {
                guard let thisContainer = self else {
                    return
                }
                self?.delegate?.performValidate(for: thisContainer, onSuccess: { [weak self] in
                    self?.hideCommonLoading {
                        self?.delegate?.mifidDidFinish()
                    }
                })
            }
        }
    }
    
    private func resetMifidNavigation(animated: Bool = true, completion: @escaping () -> Void) {
        dismissAnyModal { [weak self] in
            guard let sourceView = self?.sourceView else {
                return
            }
            DispatchQueue.main.async { // this must be done on next cycle because of loading transition (we thing uikit calls completion when transition is not yet finished)
                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    completion()
                })
                sourceView.navigationController?.popToViewController(sourceView, animated: animated)
                CATransaction.commit()
            }
        }
    }
    
    func saveParameter<P>(parameter: P) where P: OperativeParameter {
        guard let container = operativeContainer else {
            fatalError()
        }
        container.saveParameter(parameter: parameter)
    }
    
    func provideParameter<P>() -> P where P: OperativeParameter {
        guard let container = operativeContainer else {
            fatalError()
        }
        return container.provideParameter()
    }
    
    func cancelMifid() {
        resetMifidNavigation {}
    }
    
    private func dismissAnyModal(completion: @escaping () -> Void) {
        guard let current = lastModalPresented else {
            completion()
            return
        }
        guard let stepView = current.stepView as? UIViewController else {
            fatalError()
        }
        stepView.dismiss(animated: true) { [weak self] in
            self?.lastModalPresented = nil
            completion()
        }
    }
    
    func cancelOperativeTouched() {
        operativeContainer?.cancelTouched(completion: nil)
    }
}
