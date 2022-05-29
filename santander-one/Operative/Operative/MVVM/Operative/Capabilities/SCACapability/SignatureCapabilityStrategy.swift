//
//  SignatureCapabilityStrategy.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 25/1/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol SignatureCapabilityStrategy: SCACapabilityStrategy {
    associatedtype Operative: ReactiveOperative
    var operative: Operative { get }
    var validateStep: Operative.StepType { get }
    var signatureStep: Operative.StepType { get }
    var signaturePublisher: Deferred<AnyPublisher<Void, Error>> { get }
}

extension SignatureCapabilityStrategy {
    public func scaPublisher(for sca: SCARepresentableType) -> AnyPublisher<Void, Error> {
        return Future { promise in
            switch sca {
            case .signature(let signature):
                operative.coordinator.dataBinding.set(signature)
                operative.stepsCoordinator.add(step: signatureStep, after: validateStep)
                promise(.success(()))
            case .signatureWithToken(let signature):
                operative.coordinator.dataBinding.set(signature)
                operative.stepsCoordinator.add(step: signatureStep, after: validateStep)
                promise(.success(()))
            default:
                promise(.failure(ReactiveOperativeError.unknown))
            }
        }
        .eraseToAnyPublisher()
    }
}
