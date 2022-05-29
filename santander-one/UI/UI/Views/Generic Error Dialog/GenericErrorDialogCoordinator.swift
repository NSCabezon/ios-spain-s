//
//  GenericErrorDialogCoordinator.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 13/04/2020.
//

import Foundation
import CoreFoundationLib

public protocol GenericErrorDialogCoordinatorDelegate: AnyObject {
    func didSelectGoToBranchLocator()
}

protocol GenericErrorDialogCoordinatorProtocol {
    func dismiss()
    func goToGlobalPosition()
    func goToWeb(_ url: URL)
    func goToPhoneCall(_ phone: String)
    func goToBranchLocator()
}

class GenericErrorDialogCoordinator {
    
    weak var viewController: UIViewController?
    let dependenciesEngine: DependenciesDefault
    let action: (() -> Void)?
    let closeAction: (() -> Void)?
    
    init(dependenciesResolver: DependenciesResolver,
         viewController: UIViewController,
         action: (() -> Void)? = nil,
         closeAction: (() -> Void)? = nil) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.viewController = viewController
        self.action = action
        self.closeAction = closeAction
        self.setupDependencies()
    }
    
    func start() {
        let dialogViewController = self.dependenciesEngine.resolve(for: GenericErrorDialogViewController.self)
        dialogViewController.modalPresentationStyle = .overCurrentContext
        dialogViewController.modalTransitionStyle = .crossDissolve
        self.viewController?.present(dialogViewController, animated: true, completion: nil)
    }
}

private extension GenericErrorDialogCoordinator {
    
    func setupDependencies() {
        self.dependenciesEngine.register(for: GenericErrorDialogPresenterProtocol.self) { resolver in
            return GenericErrorDialogPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GenericErrorDialogViewController.self) { resolver in
            let presenter: GenericErrorDialogPresenterProtocol = resolver.resolve()
            let viewController = GenericErrorDialogViewController(nibName: "GenericErrorDialogViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: GetGenericErrorDialogDataUseCaseProtocol.self) { resolver in
            return GetGenericErrorDialogDataUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GenericErrorDialogCoordinatorProtocol.self) { _ in
            return self
        }
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        self.viewController?.presentedViewController?.dismiss(animated: true, completion: completion)
    }
}

extension GenericErrorDialogCoordinator: GenericErrorDialogCoordinatorProtocol {
    
    func dismiss() {
        self.dismiss { [weak self] in
            self?.closeAction?()
        }
    }
    
    func goToGlobalPosition() {
        self.dismiss { [weak self] in
            self?.viewController?.navigationController?.popToRootViewController(animated: true)
            guard let action = self?.action else { return }
            action()
        }
    }
    
    func goToWeb(_ url: URL) {
        self.dismiss {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func goToPhoneCall(_ phone: String) {
        guard let phone = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") else { return }
        self.dismiss {
            UIApplication.shared.open(phone, options: [:], completionHandler: nil)
        }
    }
    
    func goToBranchLocator() {
        self.dismiss { [weak self] in
            self?.dependenciesEngine.resolve(forOptionalType: GenericErrorDialogCoordinatorDelegate.self)?.didSelectGoToBranchLocator()
            guard let action = self?.action else { return }
            action()
        }
    }
}
