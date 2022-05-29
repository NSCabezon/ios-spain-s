//
//  PGClassicCoordinator.swift
//  GlobalPosition
//
//  Created by alvola on 28/10/2019.
//
import CoreFoundationLib
import UI

final class PGClassicCoordinator {
    private let resolver: DependenciesResolver
    weak var navigationController: UINavigationController?
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
        injector.register(for: PGClassicPresenterProtocol.self) { PGClassicPresenter(resolver: $0) }
        injector.register(for: PGClassicViewController.self) { resolver in
            let presenter: PGClassicPresenterProtocol = resolver.resolve(for: PGClassicPresenterProtocol.self)
            let view: PGClassicViewController = PGClassicViewController(presenter: presenter, dependenciesResolver: resolver)
            presenter.dataManager = resolver.resolve(for: PGDataManagerProtocol.self)
            presenter.view = view
            return view
        }
        injector.register(for: ClassicShortcutsViewController.self) { _ in
            ClassicShortcutsViewController(nibName: "ClassicShortcutsViewController", bundle: Bundle(for: ClassicShortcutsViewController.self))
        }
        injector.register(for: ClassicGlobalPositionWrapperProtocol.self) { _ in
            ClassicGlobalPositionWrapper(dependenciesResolver: injector)
        }
        injector.register(for: LoanSimulationUseCase.self) { _ in
            LoanSimulationUseCase(resolver: injector)
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
        self.whatsNewCoordinator.start(.classic)
    }
    
    func goToAviosDetail() {
        aviosDetailCoordinator.start()
    }
}

// MARK: - Commons.ModuleCoordinator

extension PGClassicCoordinator: ModuleCoordinator {

    public func start() {
        let view = resolver.resolve(for: PGClassicViewController.self)
        self.navigationController?.setViewControllers([view], animated: false)
    }
    
    func dismiss() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
