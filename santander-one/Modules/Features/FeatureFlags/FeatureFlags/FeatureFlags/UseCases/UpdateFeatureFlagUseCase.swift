 //
//  UpdateFeatureFlagUseCase.swift
//  FeatureFlags
//
//  Created by José Carlos Estela Anguita on 17/3/22.
//

 import Foundation
 import OpenCombine
 import CoreDomain

 protocol UpdateFeatureFlagUseCase {
     func update(_ feature: FeatureFlagWithValue)
 }

 struct DefaultUpdateFeatureFlagUseCase {
     
     let repository: FeatureFlagsRepository
     
     init(dependencies: FeatureFlagsDependenciesResolver) {
         self.repository = dependencies.external.resolve()
     }
 }

 extension DefaultUpdateFeatureFlagUseCase: UpdateFeatureFlagUseCase {
     
     func update(_ feature: FeatureFlagWithValue) {
         repository.save(value: feature.value, for: feature.feature)
     }
 }
