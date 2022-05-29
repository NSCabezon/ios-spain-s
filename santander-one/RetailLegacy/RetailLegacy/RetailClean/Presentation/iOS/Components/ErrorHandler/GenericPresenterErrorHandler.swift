import UIKit.UIViewController
import UI
import CoreFoundationLib

protocol GenericPresenterhideLoadings: class {
    func hideAllLoadings( completion: (() -> Void)?)
}

class PrivatePresenterErrorHandler: GenericPresenterErrorHandler {
    private var sessionManager: CoreSessionManager?
    
    init(sessionManager: CoreSessionManager?, stringLoader: StringLoader, view: UIViewController, delegate: GenericPresenterhideLoadings, dependenciesResolver: DependenciesResolver) {
        self.sessionManager = sessionManager
        super.init(stringLoader: stringLoader, view: view, delegate: delegate, dependenciesResolver: dependenciesResolver)
    }
    
    override func unauthorized() {
        super.unauthorized()
        hideLoading {
            self.sessionManager?.finishWithReason(.notAuthorized)
        }
    }
}

class GenericPresenterErrorHandler: CustomUseCaseErrorHandler {
    private let stringLoader: StringLoader
    private weak var view: UIViewController?
    private weak var delegate: GenericPresenterhideLoadings?
    private let dependenciesResolver: DependenciesResolver

    init(stringLoader: StringLoader, view: UIViewController, delegate: GenericPresenterhideLoadings, dependenciesResolver: DependenciesResolver) {
        self.stringLoader = stringLoader
        self.view = view
        self.delegate = delegate
        self.dependenciesResolver = dependenciesResolver
    }
    
    func onError(keyDesc: String?, completion: @escaping () -> Void) {
        hideLoading {
            guard let view = self.view else { return }
            let accept = DialogButtonComponents(titled: self.stringLoader.getString("generic_button_accept"), does: completion)
            Dialog.alert(title: nil,
                         body: self.stringLoader.getString(keyDesc ?? "generic_error_needInternetConnection"),
                         withAcceptComponent: accept,
                         withCancelComponent: nil,
                         source: view)
        }
    }
    
    func unauthorized() { }

    func showNetworkUnavailable() {
        hideLoading {
            guard let view = self.view else { return }
            let accept = DialogButtonComponents(titled: self.stringLoader.getString("generic_button_accept"), does: nil)
            Dialog.alert(title: nil,
                         body: self.stringLoader.getString("generic_error_needInternetConnection"),
                         withAcceptComponent: accept,
                         withCancelComponent: nil,
                         source: view)
        }
    }

    func showGenericError() {
        hideLoading {
            self.showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver)
        }
    }

    func hideLoading(completion: @escaping () -> Void) {
        LoadingCreator.hideGlobalLoading {
            guard let delegate = self.delegate else {
                completion()
                return
            }
            delegate.hideAllLoadings(completion: completion)
        }
    }
}

extension GenericPresenterErrorHandler: GenericErrorDialogPresentationCapable {
    
    var associatedGenericErrorDialogView: UIViewController {
        return self.view ?? UIViewController()
    }
}
