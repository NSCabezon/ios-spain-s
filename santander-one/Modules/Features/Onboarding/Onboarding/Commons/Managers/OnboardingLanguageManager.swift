//
//  LanguageManager.swift
//  CoreTestData
//
//  Created by Jose Ignacio de Juan Díaz on 29/12/21.
//

import Foundation
import OpenCombine

protocol OnboardingLanguageManagerProtocol {
    var didLanguageUpdate: PassthroughSubject<Void, Never> { get }
}

struct OnboardingLanguageManager: OnboardingLanguageManagerProtocol {
    var didLanguageUpdate = PassthroughSubject<Void, Never>()
}
