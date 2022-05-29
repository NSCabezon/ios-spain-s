 //
//  AnalysisAreaUseCase.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 4/1/22.
//

 import Foundation
 import CoreDomain
 import OpenCombine

 public protocol AnalysisAreaUseCase {
//    func fech/*@NameMethod@*/Publisher(<#parameters#>: /*@NameRepresentable@*/Representable) -> AnyPublisher</*@NameRepresentable@*/Representable, Error>
 }

 struct DefaultAnalysisAreaUseCase {
   //  private let repository: /*@NAME_OF_REPOSITORY@*/Repository
     
     init(dependencies: AnalysisAreaHomeDependenciesResolver) {
  //       repository = dependencies.external.resolve()
     }
 }

 extension DefaultAnalysisAreaUseCase: AnalysisAreaUseCase {
//    func fech/*@NameMethod@*/Publisher(<#parameters#>: /*@NameRepresentable@*/Representable){
//        self.repository.loadData()
//    }
 }
