//
//  BizumHomeModuleCoordinator.swift
//  Bizum
//
//  Created by Carlos Gutiérrez Casado on 09/09/2020.
//

import CoreFoundationLib
import UI
import SANLibraryV3

public protocol BizumHomeModuleCoordinatorDelegate: class {
    func didSelectMenu()
    func goToBizumRequestMoney(_ contacts: [BizumContactEntity]?)
    func goToBizumSendMoney(_ contacts: [BizumContactEntity]?)
    func goToBizumAcceptRequestMoney(_ operation: BizumHistoricOperationEntity)
    func goToBizumRefundMoney(operation: BizumHistoricOperationEntity)
    func goToBizumCancel(_ operation: BizumHistoricOperationEntity)
    func goToVirtualAssistant()
    func goToReuseSendMoney(_ contact: BizumContactEntity, bizumSendMoney: BizumSendMoney)
    func goToReuseRequestMoney(_ contact: BizumContactEntity, bizumSendMoney: BizumSendMoney)
    func goToBizumWeb(configuration: WebViewConfiguration)
    func goToBizumCancelRequest(_ operation: BizumHistoricOperationEntity)
    func goToBizumRejectSend(_ operation: BizumHistoricOperationEntity)
    func goToBizumRejectRequest(_ operation: BizumHistoricOperationEntity)
    func goToBizumSplitExpenses(_ operation: SplitableExpenseProtocol)
    func goToBizumDonations()
    func didSelectOffer(offer: OfferEntity)
    func didSelectSearch()
    func goToAmountSendMoney(_ contact: BizumContactEntity)
}

protocol BizumHomeModuleCoordinatorProtocol {
    func didSelectMenu()
    func didSelectDismiss()
    func goToBizumRequestMoney(_ contacts: [BizumContactEntity]?)
    func goToBizumSendMoney(_ contacts: [BizumContactEntity]?)
    func goToBizumAcceptRequestMoney(_ operation: BizumHistoricOperationEntity)
    func goToVirtualAssistant()
    func didSelectHistoric()
    func goToDetail(_ detail: BizumOperationEntity)
    func goToDetailOfMultipleOperation(_ operation: BizumOperationEntity)
    func goToBizumWebWithConfiguration(_ configuration: WebViewConfiguration)
    func goToBizumDonations()
    func didSelectSearch()
    func goToAmountSendMoney(_ contact: BizumContactEntity)
}

final class BizumHomeModuleCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let historicCoordinator: BizumHistoricModuleCoordinator
    private var detailModuleCoordinator: BizumDetailModuleCoordinator?
    private var detailMultipleCoordinator: BizumDetailMultipleModuleCoordinator?

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.historicCoordinator = BizumHistoricModuleCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: self.navigationController)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: BizumHomeViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension BizumHomeModuleCoordinator: BizumHomeModuleCoordinatorProtocol {
    func didSelectMenu() {
        self.delegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func goToBizumSendMoney(_ contacts: [BizumContactEntity]?) {
        self.delegate.goToBizumSendMoney(contacts)
    }

    func goToAmountSendMoney(_ contact: BizumContactEntity) {
        self.delegate.goToAmountSendMoney(contact)
    }

    func goToBizumRequestMoney(_ contacts: [BizumContactEntity]?) {
        self.delegate.goToBizumRequestMoney(contacts)
    }
    
    func goToBizumAcceptRequestMoney(_ operation: BizumHistoricOperationEntity) {
        self.delegate.goToBizumAcceptRequestMoney(operation)
    }
    
    func goToVirtualAssistant() {
        self.delegate.goToVirtualAssistant()
    }

    func didSelectHistoric() {
        self.historicCoordinator.start()
    }

    func goToDetail(_ detail: BizumOperationEntity) {
        self.dependenciesEngine.register(for: BizumHistoricOperationConfiguration.self) { _ in
            BizumHistoricOperationConfiguration(bizumHistoricOperationEntity: .simple(operation: detail))
        }
        self.detailModuleCoordinator = BizumDetailModuleCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController)
        self.detailModuleCoordinator?.start()
    }
    
    func goToDetailOfMultipleOperation(_ operation: BizumOperationEntity) {
        self.dependenciesEngine.register(for: BizumHistoricOperationConfiguration.self) { _ in
            BizumHistoricOperationConfiguration(bizumHistoricOperationEntity: .simple(operation: operation))
        }
        self.detailMultipleCoordinator = BizumDetailMultipleModuleCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController)
        self.detailMultipleCoordinator?.start()
    }
    
    func goToBizumSplitExpenses(operation: SplitableExpenseProtocol) {
        self.delegate.goToBizumSplitExpenses(operation)
    }
    
    func goToBizumWebWithConfiguration(_ configuration: WebViewConfiguration) {
        self.delegate.goToBizumWeb(configuration: configuration)
    }

    func goToBizumDonations() {
        self.delegate.goToBizumDonations()
    }
    
    func didSelectSearch() {
        self.delegate.didSelectSearch()
    }
}

private extension BizumHomeModuleCoordinator {
    var delegate: BizumHomeModuleCoordinatorDelegate {
        return self.dependenciesEngine.resolve(for: BizumHomeModuleCoordinatorDelegate.self)
    }
    
    func setupDependencies() {
        self.dependenciesEngine.register(for: BizumHomeModuleCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: BizumHomePresenterProtocol.self) { dependenciesResolver in
            let configuration: BizumCheckPaymentConfiguration = dependenciesResolver.resolve()
            return BizumHomePresenter(dependenciesResolver: dependenciesResolver, bizumCheckPaymentEntity: configuration.bizumCheckPaymentEntity)
        }
        self.dependenciesEngine.register(for: BizumHomeViewController.self) { dependenciesResolver in
            var presenter: BizumHomePresenterProtocol = dependenciesResolver.resolve(for: BizumHomePresenterProtocol.self)
            let viewController = BizumHomeViewController(nibName: "BizumHomeViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: BizumOperationUseCaseAlias.self) { dependenciesResolver in
            return BizumOperationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetFaqsUseCaseAlias.self) { dependenciesResolver in
            return GetFaqsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: BizumHomeConfigurationUseCaseAlias.self) { dependenciesResolver in
            return BizumHomeConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetContactListUseCase.self) { dependenciesResolver in
            return GetContactListUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: BizumActionsAppConfigUseCase.self) { dependenciesResolver in
            return BizumActionsAppConfigUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetBizumWebConfigurationUseCase.self) { dependenciesResolver in
            return GetBizumWebConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
            return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}
