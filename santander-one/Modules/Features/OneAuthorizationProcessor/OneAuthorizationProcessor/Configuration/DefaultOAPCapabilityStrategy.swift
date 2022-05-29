//
//  DefaultOAPCapabilityStrategy.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 25/1/22.
//

import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import Operative

public final class DefaultOAPCapabilityStrategy: SCACapabilityStrategy {
    
    private let scope: String
    private let subject = PassthroughSubject<Void, Error>()
    private let dependencies: ReactiveOperativeExternalDependencies
    
    public init(dependencies: ReactiveOperativeExternalDependencies, scope: String) {
        self.dependencies = dependencies
        self.scope = scope
    }
    
    public func scaPublisher(for sca: SCARepresentableType) -> AnyPublisher<Void, Error> {
        switch sca {
        case .oap(let authorizationId):
            goToAuthorizationProcessor(authorizationId: authorizationId, scope: scope)
            return subject.eraseToAnyPublisher()
        default:
            return Fail(error: ReactiveOperativeError.unknown).eraseToAnyPublisher()
        }
    }
}

extension DefaultOAPCapabilityStrategy: OneAuthorizationProcessorLauncher {
    
    public var dependenciesResolver: DependenciesResolver {
        return dependencies.resolve()
    }
}

extension DefaultOAPCapabilityStrategy: OneAuthorizationProcessorDelegate {
    public func authorizationDidFinishSuccessfully() {
        subject.send()
        subject.send(completion: .finished)
    }
    
    public func authorizationDidFinishWithError(_ error: Error) {
        subject.send(completion: .failure(error))
    }
}
