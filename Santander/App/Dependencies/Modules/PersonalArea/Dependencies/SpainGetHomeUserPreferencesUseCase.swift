//
//  SpainGetHomeUserPreferencesUseCase.swift
//  Santander
//
//  Created by alvola on 25/4/22.
//

import Foundation
import PersonalArea
import OpenCombine
import CoreFoundationLib
import CoreDomain

struct SpainGetHomeUserPreferencesUseCase {
    private let localAppConfig: LocalAppConfig
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependencies: PersonalAreaHomeExternalDependenciesResolver) {
        self.localAppConfig = dependencies.resolve()
        self.appConfigRepository = dependencies.resolve()
    }
}

extension SpainGetHomeUserPreferencesUseCase: GetHomeUserPreferencesUseCase {
    func fetchUserPreferences() -> AnyPublisher<PersonalAreaDigitalProfileAndSecurityEnable, Never> {
        return self.appConfigRepository
            .value(for: PersonalAreaConstants.isPersonalAreaSecuritySettingEnabled, defaultValue: false)
            .map { respose in
                return PersonalAreaDigitalProfileAndSecurityEnable(isEnabledDigitalProfileView: localAppConfig.isEnabledDigitalProfileView,
                                                                   isPersonalAreaSecuritySettingEnabled: respose)
            }
            .eraseToAnyPublisher()
    }
}
