//
//  BizumMoneyRequestOperative.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 19/11/2020.
//

import Operative
import CoreFoundationLib
import UI

final class BizumRequestMoneyOperative: BizumMoneyOperative {
    var dependencies: DependenciesInjector & DependenciesResolver
    var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    private lazy var operativeData: BizumRequestMoneyOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    var steps: [OperativeStep] = []
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        dependencies.resolve(for: BizumFinishingCoordinatorProtocol.self)
    }()
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
}

extension BizumRequestMoneyOperative: OperativeRebuildStepsCapable {
    func rebuildSteps() {
        let type = self.operativeData.typeUserInSimpleSend
        self.steps.removeAll()
        self.steps.append(BizumContactSelectorStep(dependenciesResolver: dependencies))
        self.steps.append(BizumAmountStep(dependenciesResolver: dependencies))
        switch type {
        case .noRegister: break
        case .register:
            self.steps.append(BizumConfirmationStep(dependenciesResolver: dependencies))
        }
        self.steps.append(BizumSendMoneySummaryStep(dependenciesResolver: dependencies))
    }
}

private extension BizumRequestMoneyOperative {
    func buildSteps() {
        self.steps.append(BizumContactSelectorStep(dependenciesResolver: dependencies))
        self.steps.append(BizumAmountStep(dependenciesResolver: dependencies))
        self.steps.append(BizumConfirmationStep(dependenciesResolver: dependencies))
        self.steps.append(BizumSendMoneySummaryStep(dependenciesResolver: dependencies))
    }
    
    func setupDependencies() {
        self.setupContacts()
        self.setupAmount()
        self.setupAmountUseCases()
        self.setupConfirmation()
        self.setupSummary()
        self.setupInviteUseCase()
        self.dependencies.register(for: BizumWebViewConfigurationUseCaseProtocol.self) { dependenciesResolver in
            return BizumWebViewConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
    }

    func setupAmountUseCases() {
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
            BizumRequestMoneyConfirmationPresenter(dependenciesResolver: resolver)
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
        self.dependencies.register(for: BizumSendMoneySummaryPresenterProtocol.self) { resolver in
            return BizumRequestMoneySummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumSendMoneySummaryPresenterProtocol.self)
            let viewController = BizumSummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: GetGlobalPositionUseCaseAlias.self) { dependenciesResolver in
            return GetGlobalPositionUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
    
    func setupInviteUseCase() {
        self.dependencies.register(for: BizumRequestMoneyInviteClientUseCase.self) { dependenciesResolver in
            return BizumRequestMoneyInviteClientUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}

extension BizumRequestMoneyOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-bizum-solicitud-exito")
    }
}

extension BizumRequestMoneyOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-bizum-solicitud-abandono")
    }
}

extension BizumRequestMoneyOperative: OperativeFinishingCoordinatorCapable {}

extension BizumRequestMoneyOperative: ShareOperativeCapable {
    // MARK: - ShareBizumView
    /// The modalPresentationStyle is overCurrentContext because avoid screen rotation
    func getShareView(completion: @escaping (Result<(UIShareView?, UIView?), ShareOperativeError>) -> Void) {
        guard let container = self.container else { return }
        let operativeData: BizumRequestMoneyOperativeData = container.get()
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

// MARK: - Tracker
extension BizumRequestMoneyOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return dependencies.resolve(for: TrackerManager.self)
    }
    
    var extraParametersForTracker: [String: String] {
        return [
            "": ""
        ]
    }
}

extension BizumRequestMoneyOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        self.dependencies
    }
}
