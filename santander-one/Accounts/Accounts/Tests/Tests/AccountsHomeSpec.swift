import Quick
import Nimble
import CoreFoundationLib
import SANLibraryV3
import QuickSetup
@testable import Account

class AccountsHomeSpec: QuickSpec {
    
    let quickSetup = QuickSetup.shared
    var xmlDemoExecutor: XmlDemoExecutor = {
       return XmlDemoExecutor()
    }()
    let dependenciesResolver = DependenciesDefault()
    var presenter: AccountsHomePresenter!
    
    override func spec() {
        super.spec()
        
        beforeEach {
            self.xmlDemoExecutor.addStubs([
                XmlStubResponse(for: "authenticateCredential"),
                XmlStubResponse(for: "obtenerPosGlobalConCestasInvers_LIP", response: 2),
                XmlStubResponse(for: "detallePrestamo_LA")
            ])
            self.quickSetup.soapDemoExecutor = self.xmlDemoExecutor
            self.quickSetup.doLogin(withUser: .demo)
            _ = try? self.quickSetup.managersProvider.getBsanPGManager().loadGlobalPosition(onlyVisibleProducts: true, isPB: true)
            self.setupDependencies()
            self.presenter = AccountsHomePresenter(dependenciesResolver: self.dependenciesResolver)
        }
        
        afterEach {
            self.xmlDemoExecutor.removeAll()
            self.presenter = nil
        }
    }
}

extension AccountsHomeSpec {
    
    func setupDependencies() {
        dependenciesResolver.register(for: GlobalPositionRepresentable.self) { _ in
            return self.quickSetup.getGlobalPosition()!
        }
        dependenciesResolver.register(for: BSANManagersProvider.self) { dependenciesResolver in
            return QuickSetup.shared.managersProvider
        }
        dependenciesResolver.register(for: TrackerManager.self) { _ in
            return TrackerManagerMock()
        }
        dependenciesResolver.register(for: UseCaseHandler.self) { _ in
            return UseCaseHandler(maxConcurrentOperationCount: 8, qualityOfService: .userInitiated)
        }
        dependenciesResolver.register(for: TimeManager.self) { _ in
            return TimeManagerMock()
        }
        dependenciesResolver.register(for: StringLoader.self) { _ in
            return StringLoaderMock()
        }
    }
}
