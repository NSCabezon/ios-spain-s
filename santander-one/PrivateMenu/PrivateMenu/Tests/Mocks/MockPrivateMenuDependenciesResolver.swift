import CoreDomain
import CoreFoundationLib
import CoreTestData
import UI

@testable import PrivateMenu

struct MockPrivateMenuDependenciesResolver: PrivateMenuDependenciesResolver {
    var external: PrivateMenuExternalDependenciesResolver
    public var injector: MockDataInjector
    
    init(injector: MockDataInjector) {
        self.injector = injector
        self.external = MockExternalDependencies(injector: injector)
    }
    
    func resolve() -> PrivateMenuCoordinator {
        fatalError()
    }
    
    func resolve() -> DataBinding {
        fatalError()
    }
    
    func resolve() -> GetDigitalProfilePercentageUseCase {
        fatalError()
    }
    
    func resolve() -> GetNameUseCase {
        fatalError()
    }

    func resolve() -> MockPrivateMenuCoordinator {
        fatalError()
    }
    
    func resolve() -> GetPrivateMenuOptionEnabledUseCase {
        fatalError()
    }
}

protocol MockPrivateMenuCoordinator: BindableCoordinator {
    func gotoSecurity()
    func gotoAtms()
    func gotoHelpCenter()
    func gotoMyManager()
    func gotoPersonalArea()
    func logout()
}
