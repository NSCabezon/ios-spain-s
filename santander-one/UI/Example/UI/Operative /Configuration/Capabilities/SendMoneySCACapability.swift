//
//  SendMoneySCACapability.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 25/1/22.
//

import Operative
import OpenCombine
import CoreDomain
import SANLegacyLibrary

struct SendMoneySCACapability: SCACapability {
    
    let operative: SendMoneyOperative
    let validateStep: SendMoneyStep = .selectDestination

    var validatePublisher: AnyPublisher<SCARepresentable, Error> {
        return Just(OTPValidationDTO()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    var scaStrategies: [SCACapabilityStrategyType: SCACapabilityStrategy] {
        return [
            .otp: SendMoneyOTPStrategy(operative: operative)
        ]
    }
}

struct SendMoneyOTPStrategy: OTPCapabilityStrategy {
    
    let operative: SendMoneyOperative
    let validateStep: SendMoneyStep = .selectDestination
    let otpStep: SendMoneyStep = .otp
    var otpPublisher: Deferred<AnyPublisher<Void, Error>> {
        return Deferred { Just(()).setFailureType(to: Error.self).eraseToAnyPublisher() }
    }
}
