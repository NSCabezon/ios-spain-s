//
//  MockGetHomeUserPreferencesUseCase.swift
//  PersonalArea-Unit-Tests
//
//  Created by alvola on 11/5/22.
//

import Foundation
import PersonalArea
import OpenCombine

struct MockGetHomeUserPreferencesUseCase: GetHomeUserPreferencesUseCase {
    func fetchUserPreferences() -> AnyPublisher<PersonalAreaDigitalProfileAndSecurityEnable, Never> {
        return Just(PersonalAreaDigitalProfileAndSecurityEnable(isEnabledDigitalProfileView: true,
                                                                isPersonalAreaSecuritySettingEnabled: true))
            .eraseToAnyPublisher()
    }
}
