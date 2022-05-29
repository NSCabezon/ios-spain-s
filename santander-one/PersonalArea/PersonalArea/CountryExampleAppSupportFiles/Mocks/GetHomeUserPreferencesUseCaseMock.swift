//
//  GetHomeUserPreferencesUseCaseMock.swift
//  PersonalArea
//
//  Created by alvola on 26/4/22.
//

import Foundation
import OpenCombine

public final class GetHomeUserPreferencesUseCaseMock: GetHomeUserPreferencesUseCase {
    public init() {}
    
    public func fetchUserPreferences() -> AnyPublisher<PersonalAreaDigitalProfileAndSecurityEnable, Never> {
        return Just(PersonalAreaDigitalProfileAndSecurityEnable(isEnabledDigitalProfileView: true,
                                                                isPersonalAreaSecuritySettingEnabled: true))
            .eraseToAnyPublisher()
    }
}
