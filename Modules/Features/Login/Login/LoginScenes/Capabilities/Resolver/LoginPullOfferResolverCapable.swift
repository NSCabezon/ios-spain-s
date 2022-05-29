//
//  LoginPullOfferCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/25/20.
//

import Foundation
import CoreFoundationLib

protocol LoginPullOfferResolverCapable {
    var dependenciesEngine: DependenciesDefault { get }
}

extension LoginPullOfferResolverCapable {
    func registerPullOfferDependencies() {
        self.dependenciesEngine.register(for: LoginPullOfferLayer.self) { resolver in
            return LoginPullOfferLayer(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: TrusteerUseCase.self) { resolver in
           return TrusteerUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: PullOfferCandidatesUseCase.self) { resolver in
           return PullOfferCandidatesUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: SetupPublicPullOffersSuperUseCase.self) { resolver in
           return SetupPublicPullOffersSuperUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: SetupPullOffersUseCase.self) { resolver in
           return SetupPullOffersUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: LoadPublicPullOffersVarsUseCase.self) { resolver in
           return LoadPublicPullOffersVarsUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: CalculateLocationsUseCase.self) { resolver in
           return CalculateLocationsUseCase(dependenciesResolver: resolver)
        }
    }
}
