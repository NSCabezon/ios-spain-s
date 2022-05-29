import UI
import CoreFoundationLib
import CoreDomain

public protocol OperativeContainerCoordinatorDelegate: AnyObject {
    func handleOpinator(_ opinator: OpinatorInfoRepresentable)
    func handleGiveUpOpinator(_ opinator: OpinatorInfoRepresentable, completion: @escaping () -> Void)
    func handleWebView(with data: Data, title: String)
    func executeOffer(_ offer: OfferRepresentable)
}

public protocol OperativeContainerCoordinatorProtocol {
    var navigationController: UINavigationController? { get set }
    var sourceView: UIViewController? { get set }
    func presentModal(_ step: OperativeView)
    func push(_ step: OperativeView)
    func handleOpinator(_ opinator: OpinatorInfoRepresentable)
    func handleGiveUpOpinator(_ opinator: OpinatorInfoRepresentable, completion: @escaping () -> Void)
    func share(_ shareable: Shareable, type: ShareType?)
    func handleWebView(with data: Data, title: String)
    func executeOffer(_ offer: OfferRepresentable)
    var operativeViews: [OperativeView] { get }
    func append(_ step: OperativeView)
}

class OperativeContainerCoordinator {
    
    weak var navigationController: UINavigationController?
    weak var sourceView: UIViewController?
    let dependenciesResolver: DependenciesResolver
    
    init(navigationController: UINavigationController, dependenciesResolver: DependenciesResolver) {
        self.navigationController = navigationController
        self.dependenciesResolver = dependenciesResolver
        self.sourceView = navigationController.viewControllers.last
    }
}

extension OperativeContainerCoordinator: OperativeContainerCoordinatorProtocol {
    var operativeViews: [OperativeView] {
        self.navigationController?.viewControllers.compactMap({ $0 as? OperativeView }) ?? []
    }
    
    func presentModal(_ step: OperativeView) {
        self.performBeforePresenting {
            self.navigationController?.present(step.associatedViewController, animated: true, completion: nil)
        }
    }
    
    func push(_ step: OperativeView) {
        self.performBeforePresenting {
            self.navigationController?.blockingPushViewController(step.associatedViewController, animated: !UIAccessibility.isVoiceOverRunning)
        }
    }
    
    func handleOpinator(_ opinator: OpinatorInfoRepresentable) {
        dependenciesResolver.resolve(for: OperativeContainerCoordinatorDelegate.self).handleOpinator(opinator)
    }
    
    func handleGiveUpOpinator(_ opinator: OpinatorInfoRepresentable, completion: @escaping () -> Void) {
        dependenciesResolver.resolve(for: OperativeContainerCoordinatorDelegate.self).handleGiveUpOpinator(opinator, completion: completion)
    }
    
    func handleWebView(with data: Data, title: String) {
        dependenciesResolver.resolve(for: OperativeContainerCoordinatorDelegate.self).handleWebView(with: data, title: title)
    }
    
    func share(_ shareable: Shareable, type: ShareType? = .text) {
        guard let viewController = self.navigationController?.viewControllers.last, let type = type else { return }
        let shareHandler = SharedHandler()
        shareHandler.doShare(for: shareable, in: viewController, type: type)
    }
    
    func executeOffer(_ offer: OfferRepresentable) {
        dependenciesResolver.resolve(for: OperativeContainerCoordinatorDelegate.self).executeOffer(offer)
    }

    func append(_ step: OperativeView) {
        self.navigationController?.viewControllers.append(step.associatedViewController)
    }
    
    private func performBeforePresenting(_ presentation: @escaping () -> Void) {
        guard
            let operativeView = navigationController?.viewControllers.last as? UIViewController & OperativeView
        else {
            return presentation()
        }
        if !operativeView.operativePresenter.isBackable {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                Async.after(seconds: 2.0) {
                    guard let index = self.navigationController?.viewControllers.firstIndex(of: operativeView) else { return }
                    self.navigationController?.viewControllers.remove(at: index)
                }
            }
            presentation()
            CATransaction.commit()
        } else {
            presentation()
        }
    }
}
