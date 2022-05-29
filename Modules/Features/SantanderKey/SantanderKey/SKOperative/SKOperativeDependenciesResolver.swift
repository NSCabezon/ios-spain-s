//
//  SKOperativeDependenciesResolver.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 22/2/22.
//

import UI
import CoreFoundationLib
import OpenCombine
import CoreDomain
import Operative

protocol SKOperativeDependenciesResolver {
    var external: SKOperativeExternalDependenciesResolver { get }
    func resolve() -> DataBinding
    func resolve() -> SKOperative
    func resolve() -> SKOperativeCoordinator
    func resolve() -> StepsCoordinator<SKOperativeStep>
    func resolve() -> SKDeviceAliasDependenciesResolver
    func resolve() -> SKBiometricsDependenciesResolver
    func resolve() -> SKCardSelectorDependenciesResolver
    func resolve() -> SKPinStepDependenciesResolver
    func resolve() -> ReactiveOperativeSignatureExternalDependenciesResolver
    func resolve() -> ReactiveOperativeOTPExternalDependenciesResolver 
}

struct ReactiveOperativeSignatureDependency: ReactiveOperativeSignatureExternalDependenciesResolver {

     let dependencies: SKOperativeExternalDependenciesResolver
     let dataBinding: DataBinding
     let coordinator: SKOperativeCoordinator
     let operative: SKOperative

     func resolve() -> UINavigationController {
         return dependencies.resolve()
     }

     func resolve() -> DependenciesResolver {
         return dependencies.resolve()
     }

     func resolve() -> DataBinding {
         return operative.dataBinding
     }

     func resolve() -> SKOperative {
         return operative
     }

     func resolve() -> SignatureViewModelProtocol {
         return ReactiveOperativeSignatureViewModel(
            dependencies: self,
            capability: SKOperativeSignatureStrategy(operative: operative, dependencies: dependencies))
     }

     func resolve() -> OperativeCoordinator {
         return coordinator
     }
 }

 struct ReactiveOperativeOTPDependency: ReactiveOperativeOTPExternalDependenciesResolver {

     let dependencies: SKOperativeExternalDependenciesResolver
     let dataBinding: DataBinding
     let coordinator: SKOperativeCoordinator
     let operative: SKOperative

     func resolve() -> UINavigationController {
         return dependencies.resolve()
     }

     func resolve() -> DependenciesResolver {
         return dependencies.resolve()
     }

     func resolve() -> DataBinding {
         return operative.dataBinding
     }

     func resolve() -> SKOperative {
         return operative
     }

     func resolve() -> OTPViewModelProtocol {
         return ReactiveOperativeOTPViewModel(dependencies: self, capability: SKOperativeOTPStrategy(operative: operative, dependencies: dependencies))
     }

     func resolve() -> OperativeCoordinator {
         return coordinator
     }

     func resolve() -> OTPConfigurationProtocol? {
         let dependenciesResolver: DependenciesResolver = dependencies.resolve()
         return dependenciesResolver.resolve(forOptionalType: OTPConfigurationProtocol.self)
     }

     func resolve() -> APPNotificationManagerBridgeProtocol? {
         let dependenciesResolver: DependenciesResolver = dependencies.resolve()
         return dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)
     }
 }
