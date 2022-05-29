//
//  SendMoneyTransferTypeStep.swift
//  Santander
//
//  Created by Angel Abad Perez on 25/11/21.
//

import Operative
import CoreFoundationLib

final class SendMoneyTransferTypeStep: OperativeStep {
    let dependencies: DependenciesResolver & DependenciesInjector
    var presentationType: OperativeStepPresentationType {
        return .inNavigation(showsBack: true, showsCancel: true)
    }
    var view: OperativeView? {
        self.dependencies.resolve(for: SendMoneyTransferTypeView.self)
    }
    var floatingButtonTitleKey: String {
        return "sendMoney_button_transferDetails"
    }
    
    init(dependencies: DependenciesResolver & DependenciesInjector) {
        self.dependencies = dependencies
        setup(dependencies: dependencies)
    }
}

private extension SendMoneyTransferTypeStep {
    func setup(dependencies: DependenciesResolver & DependenciesInjector) {
        self.dependencies.register(for: SendMoneyTransferTypePresenterProtocol.self) { dependenciesResolver in
            return SendMoneyTransferTypePresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: SendMoneyTransferTypeView.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: SendMoneyTransferTypePresenterProtocol.self)
            let viewController = SendMoneyTransferTypeViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
