//
//  OneAuthorizationProcessorLauncher.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 5/10/21.
//

import Foundation
import CoreFoundationLib

public extension OneAuthorizationProcessorLauncher {
    
    func goToAuthorizationProcessor(authorizationId: String, scope: String) {
        let dependencies = DependenciesDefault(father: dependenciesResolver)
        registerDependencies(on: dependencies)
        DefaultOneAuthorizationProcessor(dependenciesResolver: dependencies).start(authorizationId: authorizationId, scope: scope)
    }
}

private extension OneAuthorizationProcessorLauncher {
    
    func registerDependencies(on dependencies: DependenciesInjector) {
        dependencies.register(for: ConfirmChallengesUseCase.self) { resolver in
            return DefaultConfirmChallengesUseCase(dependenciesResolver: resolver)
        }
        dependencies.register(for: GetChallengesUseCase.self) { resolver in
            return DefaultGetChallengesUseCase(dependenciesResolver: resolver)
        }
        dependencies.register(for: AuthorizeOperationUseCase.self) { resolver in
            return DefaultAuthorizeOperationUseCase(dependenciesResolver: resolver)
        }
    }
}
