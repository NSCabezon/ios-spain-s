//
//  SpainGetPersonalAreaHomeConfigurationUseCase.swift
//  Santander
//
//  Created by alvola on 18/4/22.
//

import Foundation
import OpenCombine
import PersonalArea

struct SpainGetPersonalAreaHomeConfigurationUseCase: GetPersonalAreaHomeConfigurationUseCase {
    func fetchPersonalAreaHomeConfiguration() -> AnyPublisher<PersonalAreaHomeRepresentable, Never> {
        return Just(SpainPersonalAreaHome()).eraseToAnyPublisher()
    }
}

private extension SpainGetPersonalAreaHomeConfigurationUseCase {
    struct SpainPersonalAreaHome: PersonalAreaHomeRepresentable {
        var isEnabledDigitalProfileView: Bool = true
        var digitalProfileInfo: PersonalAreaDigitalProfileRepresentable?
        var isPersonalAreaSecuritySettingEnabled: Bool = true
        var isPersonalDocOfferEnabled: Bool = true
        var isRecoveryOfferEnabled: Bool = true
    }
}
