//
//  PGSmartCoordinator.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 19/12/2019.
//
import CoreFoundationLib
import UI

final class PGSmartCoordinator {
    
    private let resolver: DependenciesResolver
    public weak var navigationController: UINavigationController?
    private let otherOperativesCoordinator: OtherOperativesCoordinator
    private let whatsNewCoordinator: WhatsNewCoordinator
    private let aviosDetailCoordinator: AviosDetailCoordinator
    
    init(resolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        let injector: DependenciesInjector & DependenciesResolver = DependenciesDefault(father: resolver)
        self.resolver = injector
        self.otherOperativesCoordinator = OtherOperativesCoordinator(resolver: self.resolver,
                                                                     coordinatingViewController: navigationController)
        self.whatsNewCoordinator = WhatsNewCoordinator(resolver: self.resolver,
                                                       navigationController: navigationController)
        self.aviosDetailCoordinator = AviosDetailCoordinator(resolver: self.resolver,
                                                             navigationController: navigationController)
        injector.register(for: PGSmartPresenterProtocol.self) { PGSmartPresenter(resolver: $0) }
        injector.register(for: SmartGlobalPositionWrapperProtocol.self) { _ in SmartGlobalPositionWrapper(dependenciesResolver: resolver) }
        injector.register(for: PGSmartViewController.self) { resolver in
            let presenter: PGSmartPresenterProtocol = resolver.resolve(for: PGSmartPresenterProtocol.self)
            let view: PGSmartViewController = PGSmartViewController(presenter: presenter, dependenciesResolver: resolver)
            presenter.dataManager = resolver.resolve(for: PGDataManagerProtocol.self)
            presenter.view = view
            return view
        }
        injector.register(for: LoanSimulationUseCase.self) { _ in
            LoanSimulationUseCase(resolver: injector)
        }
        injector.register(for: SmartShortcutsViewController.self) { _ in
            return SmartShortcutsViewController(nibName: "SmartShortCutsViewController", bundle: Bundle(for: SmartShortcutsViewController.self))
        }
        injector.register(for: GlobalSearchUseCase.self) { _ in
            return GlobalSearchUseCase()
        }
    }
    
    func goToMoreOperateOptions() {
        (self.resolver as? DependenciesDefault)?.register(for: OtherOperativesConfiguration.self) { _ in
            return OtherOperativesConfiguration()
        }
        self.otherOperativesCoordinator.start()
    }
    
    func goToWhatsNew() {
        whatsNewCoordinator.start(.smart)
    }
    
    func goToAviosDetail() {
        aviosDetailCoordinator.start()
    }
}

// MARK: - Commons.ModuleCoordinator

extension PGSmartCoordinator: ModuleCoordinator {
    
    func start() {
        let view = resolver.resolve(for: PGSmartViewController.self)
        self.navigationController?.setViewControllers([view], animated: false)
    }
}
