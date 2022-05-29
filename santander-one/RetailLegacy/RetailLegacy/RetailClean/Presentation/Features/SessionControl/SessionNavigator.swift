import Foundation
import CoreFoundationLib

class SessionNavigator {
    var drawer: BaseMenuViewController
    let presenterProvider: PresenterProvider
    let dependenciesEngine: DependenciesResolver & DependenciesInjector
    var legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector, legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
        self.legacyExternalDependenciesResolver = legacyExternalDependenciesResolver
    }
}

extension SessionNavigator: ModalViewsObserverProtocol, PublicNavigatable {}
