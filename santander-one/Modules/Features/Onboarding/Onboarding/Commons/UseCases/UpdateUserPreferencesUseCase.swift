//
//  SetUserPreferencesUseCase.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 30/12/21.
//

import Foundation
import CoreDomain

protocol UpdateUserPreferencesUseCase {
    func updatePreferences(update: UpdateUserPreferencesRepresentable)
}

class DefaultUpdateUserPreferencesUseCase {
    private let userPreferencesRepository: UserPreferencesRepository
    
    init(dependencies: OnboardingCommonExternalDependenciesResolver) {
        self.userPreferencesRepository = dependencies.resolve()
    }
}

extension DefaultUpdateUserPreferencesUseCase: UpdateUserPreferencesUseCase {
    func updatePreferences(update: UpdateUserPreferencesRepresentable) {
        userPreferencesRepository.updateUserPreferences(update: update)
    }
}
