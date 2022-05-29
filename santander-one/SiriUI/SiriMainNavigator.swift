import IntentsUI

@available(iOS 12.0, *)
typealias RootViewController = UIViewController & INUIHostedViewControlling

@available(iOS 12.0, *)
protocol SiriMainNavigatorProtocol {
    func start(withParameters parameters: MainPresentationParameters) -> MainPresentationResult
}

@available(iOS 12.0, *)
class SiriMainNavigator {
    let presenterProvider: SiriPresenterProvider
    let navigatorProvider: SiriNavigatorProvider
    let rootViewController: RootViewController
    
    init(presenterProvider: SiriPresenterProvider, navigatorProvider: SiriNavigatorProvider, rootViewController: RootViewController) {
        self.presenterProvider = presenterProvider
        self.navigatorProvider = navigatorProvider
        self.rootViewController = rootViewController
    }
}

@available(iOS 12.0, *)
extension SiriMainNavigator: SiriMainNavigatorProtocol {
    func start(withParameters parameters: MainPresentationParameters) -> MainPresentationResult {
        guard
            let intentReponse = parameters.interaction.intentResponse as? CallToManagerIntentResponse
            else {
            return .failed
        }
        
        switch intentReponse.code {
        case .callOK:
            return presentManagerView(intentResponse: intentReponse)
        case .callOkNoManager:
            return presentNoManager()
        case .noToken:
            return presentNoTokenView()
        default:
            return presentError()
        }
    }
    
    private func presentManagerView(intentResponse: CallToManagerIntentResponse) -> MainPresentationResult {
        let viewController: ManagerViewController = instantiateViewController(withId: "ManagerScene")
        viewController.presenter = presenterProvider.getManagerPresenter(withIntentResponse: intentResponse)
        present(viewController)
        let size = CGSize(width: rootViewController.extensionContext?.hostedViewMaximumAllowedSize.width ?? 320.0, height: 150.0)
        return MainPresentationResult(handled: true, parameters: Set(), size: size)
    }
    
    private func presentNoTokenView() -> MainPresentationResult {
        let viewController: NoTokenViewController = instantiateViewController(withId: "NoTokenScene")
        viewController.presenter = presenterProvider.noTokenPresenter
        present(viewController)
        let size = CGSize(width: rootViewController.extensionContext?.hostedViewMaximumAllowedSize.width ?? 320.0, height: 150.0)
        return MainPresentationResult(handled: true, parameters: Set(), size: size)
    }
    
    private func presentNoManager() -> MainPresentationResult {
        let viewController: NoManagerViewController = instantiateViewController(withId: "NoManagerScene")
        viewController.presenter = presenterProvider.noManagerPresenter
        present(viewController)
        let size = CGSize(width: rootViewController.extensionContext?.hostedViewMaximumAllowedSize.width ?? 320.0, height: 150.0)
        return MainPresentationResult(handled: true, parameters: Set(), size: size)
    }
    
    private func presentError() -> MainPresentationResult {
        return MainPresentationResult(handled: true, parameters: Set(), size: .zero)
    }
}

@available(iOS 12.0, *)
extension SiriMainNavigator {
    private func instantiateViewController<T: UIViewController>(withId id: String) -> T {
        guard let viewController = rootViewController.storyboard?.instantiateViewController(withIdentifier: id) as? T else {
            fatalError("view controller of type \(T.self) does not exist with id \(id)")
        }
        return viewController
    }
    
    private func present(_ viewController: UIViewController) {
        rootViewController.addChild(viewController)
        rootViewController.view.addSubview(viewController.view)
        viewController.didMove(toParent: rootViewController)
    }
}
