//
 //  GetSepaInfoListUseCase.swift
 //  CoreFoundationLib
 //
 //  Created by Carlos Monfort Gómez on 21/4/22.
 //

 import Foundation
 import CoreDomain
 import CoreFoundationLib
 import OpenCombine

 public protocol GetSepaInfoListUseCase {
     func fetchSepaList() -> AnyPublisher<SepaInfoListRepresentable?, Error>
 }

 public struct DefaultGetSepaInfoListUseCase {
     private let sepaListRepository: ReactiveSepaInfoRepository

     public init(dependencies: SepaInfoDependenciesResolver) {
         self.sepaListRepository = dependencies.resolve()
     }
 }

 extension DefaultGetSepaInfoListUseCase: GetSepaInfoListUseCase {
     public func fetchSepaList() -> AnyPublisher<SepaInfoListRepresentable?, Error> {
         return sepaListRepository
             .fetchSepaInfoPublisher()
             .eraseToAnyPublisher()
     }
 }
