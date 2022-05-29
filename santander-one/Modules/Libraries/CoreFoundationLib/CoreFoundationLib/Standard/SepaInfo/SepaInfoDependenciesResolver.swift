//
 //  SepaInfoDependenciesResolver.swift
 //  CoreFoundationLib
 //
 //  Created by Carlos Monfort Gómez on 25/4/22.
 //

 import Foundation
 import CoreDomain

 public protocol SepaInfoDependenciesResolver: CoreDependenciesResolver {
     func resolve() -> ReactiveSepaInfoRepository
     func resolve() -> GetSepaInfoListUseCase
 }

 public extension SepaInfoDependenciesResolver {
     func resolve() -> ReactiveSepaInfoRepository {
         return asShared {
             SepaInfoRepository(netClient: NetClientImplementation(), assetsClient: AssetsClient(), fileClient: FileClient())
         }
     }

     func resolve() -> GetSepaInfoListUseCase {
         return DefaultGetSepaInfoListUseCase(dependencies: self)
     }
 }
