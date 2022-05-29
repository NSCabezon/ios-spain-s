 //
//  AnalysisAreaProductsConfigurationUseCase.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 15/3/22.
//

 import Foundation
 import CoreDomain
 import OpenCombine

 public protocol AnalysisAreaProductsConfigurationUseCase {

 }

 struct DefaultAnalysisAreaProductsConfigurationUseCase {
    // private let repository: /*@NAME_OF_REPOSITORY@*/Repository
     
     init(dependencies: AnalysisAreaProductsConfigurationDependenciesResolver) {
      //   repository = dependencies.external.resolve()
     }
 }

 extension DefaultAnalysisAreaProductsConfigurationUseCase: AnalysisAreaProductsConfigurationUseCase {

 }
