//
//  SCACapability.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 24/1/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol SCACapabilityStrategy {
    func scaPublisher(for sca: SCARepresentableType) -> AnyPublisher<Void, Error>
}

public enum SCACapabilityStrategyType: Hashable {
    
    case oap
    case signature
    case signatureWithToken
    case signatureAndOTP
    case otp
    case none
    
    init(from sca: SCARepresentableType) {
        switch sca {
        case .oap:
            self = .otp
        case .signature:
            self = .signature
        case .signatureWithToken:
            self = .signatureWithToken
        case .otp:
            self = .otp
        case .signatureAndOTP:
            self = .signatureAndOTP
        case .none:
            self = .none
        }
    }
}

/// The default capability for adding SCA logic. You have to define the `validateStep` for calling the `validatePublisher` and also the strategies for each sca that you want to handle in your operative.
public protocol SCACapability: Capability {
    /// The step where you want to check the SCA for the operative
    var validateStep: Operative.StepType { get }
    /// The publisher that should call to the validate service to get the SCA
    var validatePublisher: AnyPublisher<SCARepresentable, Error> { get }
    /// A dictionary of `SCACapabilityStrategyType` (otp, signature, an so on) and the `SCACapabilityStrategy` to handle that `SCACapabilityStrategyType`
    var scaStrategies: [SCACapabilityStrategyType: SCACapabilityStrategy] { get }
}

extension SCACapability {
    
    public func configure() {
        operative.willShowNextConditions.append(publisher)
    }
}

private extension SCACapability {
    
    typealias SCAType = (strategyType: SCACapabilityStrategyType, representableType: SCARepresentableType)
    
    /// The publisher that will be executed when the `validateStep` will finish. This calls the `validatePublisher` to get the sca type.
    var publisher: AnyPublisher<ConditionState, Never> {
        return Deferred {
                // Checks if the current step is the validate step
                Just(validateStep == operative.stepsCoordinator.current.type)
            }
            .filter({ $0 == true }) // only if is the validate step
            .flatMap({ _ in showLoadingPublisher() }) // show the loading
            .flatMap { _ in return validatePublisher } // call to validate service
            .flatMap(dismissLoadingPublisher) // dismiss the loading
            .map(createSCAType) // create the SCAType
            .flatMap(scaPublisher) // call to SCAStrategy for the current SCAType
            .map { _ in return .success }
            .replaceError(with: .failure)
            .eraseToAnyPublisher()
    }
    
    func showLoadingPublisher() -> AnyPublisher<Void, Error> {
        return operative.coordinator.showLoadingPublisher().setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func dismissLoadingPublisher(_ scaRepresentable: SCARepresentable) -> AnyPublisher<SCARepresentable, Error> {
        return operative.coordinator.dismissLoadingPublisher()
            .flatMap { _ in
                return Just(scaRepresentable).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func createSCAType(for scaRepresentable: SCARepresentable) -> SCAType {
        return SCAType(
            strategyType: SCACapabilityStrategyType(from: scaRepresentable.type),
            representableType: scaRepresentable.type
        )
    }
    
    func scaPublisher(for sca: SCAType) -> AnyPublisher<Void, Error> {
        guard
            let publisher = self.scaStrategies[sca.strategyType]?.scaPublisher(for: sca.representableType)
        else {
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return publisher
    }
}
