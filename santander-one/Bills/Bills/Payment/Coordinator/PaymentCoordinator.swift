//
//  PaymentCoordinator.swift
//  Bills
//
//  Created by Cristobal Ramos Laina on 07/04/2020.
//

import Foundation
import CoreFoundationLib
import UI
import Operative

public protocol PaymentCoordinatorDelegate: AnyObject {
    func didSelectPayment(accountEntity: AccountEntity?, type: BillsAndTaxesTypeOperativePayment?)
    func didSelectBillEmittersPayment(account: AccountEntity?)
}

protocol PaymentCoordinatorProtocol {
    func goToPayment(accountEntity: AccountEntity?, type: BillsAndTaxesTypeOperativePayment?)
}

final class PaymentCoordinator: ModuleCoordinator {
    
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private lazy var view: PaymentSheetView = {
        return self.dependenciesEngine.resolve(for: PaymentSheetView.self)
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
        self.dependenciesEngine.register(for: PaymentSheetView.self) { resolver in
            let presenter = resolver.resolve(for: PaymentPresenter.self)
            let view = PaymentSheetView(presenter: presenter)
            presenter.view = view
            return view
        }
        
        self.dependenciesEngine.register(for: PaymentCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: PaymentPresenter.self) { resolver in
            return PaymentPresenter(dependenciesResolver: resolver)
        }
    }
}

extension PaymentCoordinator: PaymentCoordinatorProtocol {
    func goToPayment(accountEntity: AccountEntity?, type: BillsAndTaxesTypeOperativePayment?) {
        switch type {
        case .billPayment:
            self.dependenciesEngine.resolve(for: PaymentCoordinatorDelegate.self).didSelectBillEmittersPayment(account: accountEntity)
        default:
            self.dependenciesEngine.resolve(for: PaymentCoordinatorDelegate.self).didSelectPayment(accountEntity: accountEntity, type: type)
        }
    }
}
