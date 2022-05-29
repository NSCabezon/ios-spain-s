//
//  OnboardingRepository.swift
//  CoreDomain
//
//  Created by Jose Ignacio de Juan Díaz on 2/12/21.
//

import OpenCombine

public protocol UserPreferencesRepository {
    func getUserPreferences(userId: String) -> AnyPublisher<UserPreferencesRepresentable, Error>
    func updateUserPreferences(update: UpdateUserPreferencesRepresentable)
}
