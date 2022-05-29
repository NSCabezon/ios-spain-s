//
//  SKSCACapability.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 25/3/22.
//

//import Foundation
//import Operative
//import OpenCombine
//import CoreDomain
//import SANLegacyLibrary
//
//struct SKSCACapability: SCACapability {
//
//     let operative: SKOperative
//     let validateStep: SKOperativeStep = .deviceAlias
//
//     var validatePublisher: AnyPublisher<SCARepresentable, Error> {
//         return Just(OTPValidationDTO()).setFailureType(to: Error.self).eraseToAnyPublisher()
//     }
//
//     var scaStrategies: [SCACapabilityStrategyType: SCACapabilityStrategy] {
//         return [
//             .signature: SKOperativeSignatureStrategy(operative: operative)
//         ]
//     }
// }
