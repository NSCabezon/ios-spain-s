//
//  BizumSplitExpensesOperativeExtension.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 11/01/2021.
//

import Foundation
import CoreFoundationLib
import Operative
import UI

extension BizumSplitExpensesOperative {
    func setupDependencies() {
        self.setupAmount()
        self.setupAmountUseCases()
        self.setupContactsUseCases()
        self.setupConfirmation()
        self.setupSummary()
        self.setupInviteUseCase()
        self.dependencies.register(for: BizumWebViewConfigurationUseCaseProtocol.self) { resolver in
            return BizumWebViewConfigurationUseCase(dependenciesResolver: resolver)
        }
    }
    
    func buildSteps() {
        self.steps.append(BizumSplitExpensesAmountStep(dependenciesResolver: dependencies))
        self.steps.append(BizumConfirmationStep(dependenciesResolver: dependencies))
        self.steps.append(BizumSendMoneySummaryStep(dependenciesResolver: dependencies))
    }
    
    func setupAmount() {
        self.dependencies.register(for: BizumSplitExpensesAmountPresenterProtocol.self) { resolver in
            BizumSplitExpensesAmountPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumSplitExpensesAmountViewProtocol.self) { resolver in
            resolver.resolve(for: BizumSplitExpensesAmountViewController.self)
        }
        self.dependencies.register(for: BizumSplitExpensesAmountViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumSplitExpensesAmountPresenterProtocol.self)
            let viewController = BizumSplitExpensesAmountViewController(nibName: "BizumSplitExpensesAmountViewController", presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupContactsUseCases() {
        self.dependencies.register(for: GetContactListUseCase.self) { dependenciesResolver in
            return GetContactListUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: BizumCommonPreSetupUseCaseProtocol.self) { resolver in
            BizumCommonPreSetupUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumOperationUseCaseAlias.self) { resolver in
            BizumOperationUseCase(dependenciesResolver: resolver)
        }
    }
    
    func setupAmountUseCases() {
        self.dependencies.register(for: BizumCommonPreSetupUseCaseProtocol.self) { resolver in
            BizumCommonPreSetupUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumValidateRequestMoneyUseCase.self) { dependenciesResolver in
            return BizumValidateRequestMoneyUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: BizumValidateRequestMoneyMultiUseCase.self) { dependenciesResolver in
            return BizumValidateRequestMoneyMultiUseCase(dependenciesResolver: dependenciesResolver)
        }
    }

    func setupConfirmation() {
        self.dependencies.register(for: BizumRequestMoneyUseCase.self) { resolver in
            BizumRequestMoneyUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumRequestMoneyMultiUseCase.self) { resolver in
            BizumRequestMoneyMultiUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: GetMultimediaUsersUseCase.self) { resolver in
            GetMultimediaUsersUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SendMultimediaMultiUseCase.self) { resolver in
            SendMultimediaMultiUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SendMultimediaSimpleUseCase.self) { resolver in
            SendMultimediaSimpleUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumConfirmationPresenterProtocol.self) { resolver in
            BizumSplitExpensesConfirmationPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumConfirmationViewProtocol.self) { resolver in
            resolver.resolve(for: BizumConfirmationViewController.self)
        }
        self.dependencies.register(for: BizumConfirmationViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumConfirmationPresenterProtocol.self)
            let viewController = BizumConfirmationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupSummary() {
        self.dependencies.register(for: OperativeSummaryViewProtocol.self) { resolver in
            resolver.resolve(for: OperativeSummaryViewController.self)
        }
        self.dependencies.register(for: GetGlobalPositionUseCaseAlias.self) { dependenciesResolver in
            return GetGlobalPositionUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: BizumSendMoneySummaryPresenterProtocol.self) { resolver in
            return BizumSplitExpensesSummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumSendMoneySummaryPresenterProtocol.self)
            let viewController = BizumSummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupInviteUseCase() {
        self.dependencies.register(for: BizumRequestMoneyInviteClientUseCase.self) { dependenciesResolver in
            return BizumRequestMoneyInviteClientUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}

extension BizumSplitExpensesOperative: OperativeFinishingCoordinatorCapable {}

extension BizumSplitExpensesOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return self.dependencies.resolve()
    }
    
    var extraParametersForTracker: [String: String] {
        return [:]
    }
}

extension BizumSplitExpensesOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        self.dependencies
    }
}

extension BizumSplitExpensesOperative: OperativeRebuildStepsCapable {
    func rebuildSteps() {
        let type = self.operativeData.typeUserInSimpleSend
        self.steps.removeAll()
        self.steps.append(BizumSplitExpensesAmountStep(dependenciesResolver: dependencies))
        switch type {
        case .noRegister: break
        case .register:
            self.steps.append(BizumConfirmationStep(dependenciesResolver: dependencies))
        }
        self.steps.append(BizumSendMoneySummaryStep(dependenciesResolver: dependencies))
    }
}

extension BizumSplitExpensesOperative: ShareOperativeCapable {
    // MARK: - ShareBizumView
    /// The modalPresentationStyle is overCurrentContext because avoid screen rotation
    func getShareView(completion: @escaping (Result<(UIShareView?, UIView?), ShareOperativeError>) -> Void) {
        guard let container = self.container else { return }
        let operativeData: BizumSplitExpensesOperativeData = container.get()
        let useCase = self.dependencies.resolve(for: GetGlobalPositionUseCaseAlias.self)
        Scenario(useCase: useCase)
            .execute(on: self.dependencies.resolve())
            .onSuccess { response in
                let shareView = ShareBizumView()
                let viewModel = ShareBizumSummaryViewModel(
                    bizumOperativeType: operativeData.bizumOperativeType,
                    bizumAmount: operativeData.bizumSendMoney?.amount,
                    bizumConcept: operativeData.bizumSendMoney?.concept,
                    simpleMultipleType: operativeData.simpleMultipleType,
                    bizumContacts: operativeData.bizumContactEntity,
                    sentDate: operativeData.operationDate,
                    dependenciesResolver: self.dependenciesResolver)
                viewModel.setUserName(response.globalPosition.fullName)
                shareView.modalPresentationStyle = .overCurrentContext
                shareView.loadViewIfNeeded()
                shareView.setInfoFromSummary(viewModel)
                completion(.success((shareView, shareView.containerView)))
            }.onError { _ in
                completion(.failure(.generalError))
            }
    }
}

extension BizumSplitExpensesOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-bizum-dividir-gasto-exito")
    }
}

extension BizumSplitExpensesOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-bizum-dividir-gasto-abandono")
    }
}
