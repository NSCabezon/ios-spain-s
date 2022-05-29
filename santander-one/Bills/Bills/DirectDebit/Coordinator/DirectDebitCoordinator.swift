//
//  DirectDebitCoordinator.swift
//  Bills
//
//  Created by José Carlos Estela Anguita on 06/04/2020.
//

import CoreFoundationLib
import UI

public protocol DirectDebitCoordinatorDelegate: AnyObject {
    func didSelectDirectDebit(accountEntity: AccountEntity?)
    func showAlertDialog(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?)
}

final class DirectDebitCoordinator: ModuleCoordinator {
    
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private lazy var view: DirectDebitSheetView = {
        return self.dependenciesEngine.resolve(for: DirectDebitSheetView.self)
    }()
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        self.view.load()
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: DirectDebitSheetView.self) { resolver in
            let presenter = resolver.resolve(for: DirectDebitPresenter.self)
            let view = DirectDebitSheetView(presenter: presenter)
            presenter.view = view
            return view
        }
        
        self.dependenciesEngine.register(for: DirectDebitPresenter.self) { resolver in
            return DirectDebitPresenter(dependenciesResolver: resolver)
        }
        
        self.dependenciesEngine.register(for: GetDirectDebitUrlsUseCase.self) { dependenciesResolver in
            return GetDirectDebitUrlsUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}
