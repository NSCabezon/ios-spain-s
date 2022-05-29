//
//  WhatsNewCoordinator.swift
//  GlobalPosition
//
//  Created by Laura González on 24/06/2020.
//

import CoreFoundationLib
import UI

public protocol WhatsNewCoordinatorDelegate: AnyObject {
    func gotoAccountTransactionDetail(transactionEntity: AccountTransactionEntity, in transactionList: [AccountTransactionWithAccountEntity], accountEntity: AccountEntity)
    func gotoCardTransactionDetail(transactionEntity: CardTransactionEntity, in transactionList: [CardTransactionWithCardEntity], cardEntity: CardEntity)
}

public final class WhatsNewCoordinator {
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    private var whatsNewTransitionCoordinator: WhatsNewTransitionCoordinator?
    private let lastMovementsCoordinator: LastMovementsCoordinatorProtocol
    weak public var navigationController: UINavigationController?
    weak var rootViewController: WhatsNewViewController?

    public init(resolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.whatsNewTransitionCoordinator = WhatsNewTransitionCoordinator()
        self.dependenciesEngine = DependenciesDefault(father: resolver)
        self.navigationController = navigationController
        self.lastMovementsCoordinator = LastMovementsCoordinator(dependenciesResolver: self.dependenciesEngine, navigationController: navigationController)

        self.dependenciesEngine.register(for: GetPullOffersUseCase.self) { resolver in
            return GetPullOffersUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: WhatsNewPresenterProtocol.self) { dependenciesResolver in
            return WhatsNewPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: WhatsNewViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: WhatsNewViewController.self)
        }
        
        self.dependenciesEngine.register(for: LastMovementsCoordinatorProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: LastMovementsCoordinatorProtocol.self)
        }
        
        self.dependenciesEngine.register(for: GetAccountUseCase.self) { dependenciesResolver in
            return GetAccountUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetFutureBillSuperUseCase.self) {dependenciesResolver in
            return GetFutureBillSuperUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetFutureBillUseCase.self) { dependenciesResolver in
            return GetFutureBillUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetGlobalPositionV2UseCase.self) { dependenciesResolver in
            return GetGlobalPositionV2UseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: WhatsNewViewController.self) { [unowned self] dependenciesResolver in
            let presenter: WhatsNewPresenterProtocol = dependenciesResolver.resolve(for: WhatsNewPresenterProtocol.self)
            let viewController: WhatsNewViewController = WhatsNewViewController(presenter: presenter)
            self.rootViewController = viewController
            self.rootViewController?.modalPresentationStyle = .overFullScreen
            presenter.pgDataManager = dependenciesResolver.resolve(for: PGDataManagerProtocol.self)
            presenter.view = viewController
            viewController.loadingTipsViewController = dependenciesResolver.resolve(for: LoadingTipViewController.self)
            return viewController
        }
        
        self.dependenciesEngine.register(for: WhatsNewCoordinator.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: OtherOperativesWrapper.self) { dependenciesResolver in
            return OtherOperativesWrapper(dependenciesResolver)
        }
        self.dependenciesEngine.register(for: SetReadAccountTransactionsUseCase.self) { dependenciesResolver in
            return SetReadAccountTransactionsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: SetReadCardTransactionsUseCase.self) { dependenciesResolver in
            return SetReadCardTransactionsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: LoadingTipViewController.self) { dependenciesResolver  in
            let tipsPresenter = LoadingTipPresenter(dependenciesResolver: dependenciesResolver)
            let viewController = LoadingTipViewController(presenter: tipsPresenter)
            tipsPresenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: AccountTransactionPullOfferConfigurationUseCase.self) { dependenciesResolver in
            return AccountTransactionPullOfferConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: CardTransactionPullOfferConfigurationUseCase.self) { dependenciesResolver in
            return CardTransactionPullOfferConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetUserCampaignsUseCase.self) { resolver in
            return GetUserCampaignsUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetUnreadMovementsUseCase.self) { resolver in
            return DefaultGetUnreadMovementsUseCase(dependenciesResolver: resolver)
        }
    }
}

// MARK: - ModuleCoordinator

extension WhatsNewCoordinator: ModuleSectionedCoordinator {
    public func start(_ section: GlobalPositionType) {
        switch section {
        case .classic:
            let rootVC = dependenciesEngine.resolve(for: PGClassicViewController.self)
            whatsNewTransitionCoordinator = rootVC.bubbleTransitionCoordinator
        case .smart:
            let rootVC = dependenciesEngine.resolve(for: PGSmartViewController.self)
            whatsNewTransitionCoordinator = rootVC.bubbleTransitionCoordinator
        case .simple:
            let rootVC = dependenciesEngine.resolve(for: PGSimpleViewController.self)
            whatsNewTransitionCoordinator = rootVC.bubbleTransitionCoordinator
        }
        
        let fakeWhatsNewViewController = UIViewController()
        fakeWhatsNewViewController.view.backgroundColor = .iceBlue
        fakeWhatsNewViewController.modalPresentationStyle = .custom
        fakeWhatsNewViewController.transitioningDelegate = whatsNewTransitionCoordinator
        self.navigationController?.present(fakeWhatsNewViewController, animated: true, completion: {
            fakeWhatsNewViewController.dismiss(animated: false, completion: {
                let whatsNewViewController = self.dependenciesEngine.resolve(for: WhatsNewViewController.self)
                self.navigationController?.blockingPushViewController(whatsNewViewController, animated: false)
            })
        })
    }
    
    public func startWithOutFakeAnimation() {
        self.dependenciesEngine.register(for: PGDataManagerProtocol.self) { dependenciesResolver in
            return PGDataManager(resolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetLastLoginDateUseCase.self) { resolver in
            return GetLastLoginDateUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: PendingSolicitudesPresenterProtocol.self) { resolver in
            return PendingSolicitudesPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetAppVersionUseCase.self) { resolver in
            return GetAppVersionUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetPreconceivedBannerUseCase.self) { resolver in
            return GetPreconceivedBannerUseCase(resolver: resolver)
        }
        self.dependenciesEngine.register(for: GetPendingSolicitudesUseCase.self) { resolver in
            return GetPendingSolicitudesUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: RemoveSavedPendingSolicitudesUseCase.self) { resolver in
            return RemoveSavedPendingSolicitudesUseCase(dependenciesResolver: resolver)
        }
        let whatsNewViewController = self.dependenciesEngine.resolve(for: WhatsNewViewController.self)
        self.navigationController?.blockingPushViewController(whatsNewViewController, animated: true)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSelectPayments(_ section: LastMovementsConfiguration.FractionableSection, lastMovementsViewModel: WhatsNewLastMovementsViewModel) {
        self.dependenciesEngine.register(for: LastMovementsConfiguration.self) { _ in
            return LastMovementsConfiguration(section, lastMovementesViewModel: lastMovementsViewModel)
        }
        self.lastMovementsCoordinator.start()
    }
}
