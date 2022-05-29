import Foundation
import CoreFoundationLib

final class PersonalAreaOperativesPresenterProvider {
    
    let navigatorProvider: NavigatorProvider
    let sessionManager: CoreSessionManager
    let dependencies: PresentationComponent
    
    init(navigatorProvider: NavigatorProvider, sessionManager: CoreSessionManager, dependencies: PresentationComponent) {
        self.navigatorProvider = navigatorProvider
        self.sessionManager = sessionManager
        self.dependencies = dependencies
    }
    
    var activateSignaturePresenter: ActivateAndChangeSignPresenter {
        let activateSignature = ActivateAndChangeSignPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
        activateSignature.typeOperative = .activateSignature
        return activateSignature
    }
    
    var changeSignaturePresenter: ActivateAndChangeSignPresenter {
        let changeSignature = ActivateAndChangeSignPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
        changeSignature.typeOperative = .changeSignature
        return changeSignature
    }
}
