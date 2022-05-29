//
//  OTPCapabilityStrategy.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 25/1/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol OTPCapabilityStrategy: SCACapabilityStrategy {
    associatedtype Operative: ReactiveOperative
    var operative: Operative { get }
    var validateStep: Operative.StepType { get }
    var otpStep: Operative.StepType { get }
    var otpPublisher: Deferred<AnyPublisher<Void, Error>> { get }
}

extension OTPCapabilityStrategy {
    public func scaPublisher(for sca: SCARepresentableType) -> AnyPublisher<Void, Error> {
        return Future { promise in
            switch sca {
            case .otp(let otp):
                operative.coordinator.dataBinding.set(otp)
                operative.stepsCoordinator.add(step: otpStep, after: validateStep)
                promise(.success(()))
            default:
                promise(.failure(ReactiveOperativeError.unknown))
            }
        }
        .eraseToAnyPublisher()
    }
}
