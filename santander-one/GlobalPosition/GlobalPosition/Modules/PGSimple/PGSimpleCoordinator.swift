import CoreFoundationLib
import UI

final class PGSimpleCoordinator {
    
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
        injector.register(for: PGSimplePresenterProtocol.self) { PGSimplePresenter(resolver: $0) }
        injector.register(for: PGSimpleViewController.self) { resolver in
            let presenter: PGSimplePresenterProtocol = resolver.resolve(for: PGSimplePresenterProtocol.self)
            let view: PGSimpleViewController = PGSimpleViewController(presenter: presenter, dependenciesResolver: resolver)
            presenter.dataManager = resolver.resolve(for: PGDataManagerProtocol.self)
            presenter.view = view
            return view
        }
        
        injector.register(for: SimpleGlobalPositionWrapperProtocol.self) { _ in SimpleGlobalPositionWrapper(dependenciesResolver: resolver) }
    }
    
    func goToMoreOperateOptions() {
        (self.resolver as? DependenciesDefault)?.register(for: OtherOperativesConfiguration.self) { _ in
            return OtherOperativesConfiguration()
        }
        self.otherOperativesCoordinator.start()
    }
    
    func goToWhatsNew() {
        whatsNewCoordinator.start(.simple)
    }
    
    func goToAviosDetail() {
        aviosDetailCoordinator.start()
    }
}

// MARK: - Commons.ModuleCoordinator

extension PGSimpleCoordinator: ModuleCoordinator {
    func startFromPGSimple() {
        self.start()
    }
    
    func start() {
        let view = resolver.resolve(for: PGSimpleViewController.self)
        self.navigationController?.setViewControllers([view], animated: false)
    }
}
