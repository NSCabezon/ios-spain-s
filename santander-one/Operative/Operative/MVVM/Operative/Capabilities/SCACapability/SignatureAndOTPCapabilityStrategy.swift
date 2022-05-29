//
//  SignatureAndOTPCapabilityStrategy.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 25/1/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol SignatureAndOTPCapabilityStrategy {
    associatedtype Operative: ReactiveOperative
    var operative: Operative { get }
    var validateStep: Operative.StepType { get }
    var signatureStep: Operative.StepType { get }
    var otpStep: Operative.StepType { get }
    var signaturePublisher: Deferred<AnyPublisher<Void, Error>> { get }
    var otpPublisher: Deferred<AnyPublisher<Void, Error>> { get }
}

extension SignatureAndOTPCapabilityStrategy {
    public func scaPublisher(for sca: SCARepresentableType) -> AnyPublisher<Void, Error> {
        return Future { promise in
            switch sca {
            case .signature(let signature):
                operative.coordinator.dataBinding.set(signature)
                operative.stepsCoordinator.add(step: signatureStep, after: validateStep)
                promise(.success(()))
            case .otp(let otp):
                operative.coordinator.dataBinding.set(otp)
                operative.stepsCoordinator.add(step: otpStep, after: validateStep)
                promise(.success(()))
            case .signatureWithToken(let signature):
                operative.coordinator.dataBinding.set(signature)
                operative.stepsCoordinator.add(step: signatureStep, after: validateStep)
                promise(.success(()))
            case .signatureAndOTP(let signatureAndOTP):
                operative.coordinator.dataBinding.set(signatureAndOTP)
                operative.stepsCoordinator.add(step: signatureStep, after: validateStep)
                operative.stepsCoordinator.add(step: otpStep, after: signatureStep)
                promise(.success(()))
            default:
                promise(.failure(ReactiveOperativeError.unknown))
            }
        }
        .eraseToAnyPublisher()
    }
}
