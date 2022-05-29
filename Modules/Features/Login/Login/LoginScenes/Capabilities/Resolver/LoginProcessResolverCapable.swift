//
//  File.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/25/20.
//

import Foundation
import CoreFoundationLib

protocol LoginProcessResolverCapable {
    var dependenciesEngine: DependenciesDefault { get }
}

extension LoginProcessResolverCapable {
    func registerLoginProcessDepencencies() {
        self.dependenciesEngine.register(for: LoginProcessLayerProtocol.self) { resolver in
            return LoginProcessLayer(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LoginUseCase.self) { resolver in
            return LoginUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LoginWithPersistedUserUseCase.self) { resolver in
            LoginWithPersistedUserUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetLoginErrorLinksUseCase.self) { resolver in
            return GetLoginErrorLinksUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LocalValidationProtocol.self) { resolver in
             return LocalValidation(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: DocumentValidator.self) { _ in
            return DocumentValidator()
        }
        self.dependenciesEngine.register(for: DocumentFormatterProtocol.self) { _ in
            return DocumentFormatter()
        }
        self.dependenciesEngine.register(for: InsertConnectionDateUseCase.self) { resolver in
            return InsertConnectionDateUseCase(dependenciesResolver: resolver)
        }
    }
}
