//
//  GetPersonalAreaHomeConfigurationUseCaseMock.swift
//  PersonalArea
//
//  Created by alvola on 7/4/22.
//

import Foundation
import OpenCombine
import CoreDomain

public final class GetPersonalAreaHomeConfigurationUseCaseMock: GetPersonalAreaHomeConfigurationUseCase {
    public init() {}
    
    public func fetchPersonalAreaHomeConfiguration() -> AnyPublisher<PersonalAreaHomeRepresentable, Never> {
        return Just(PersonalAreaHomeMock()).eraseToAnyPublisher()
    }
}

private extension GetPersonalAreaHomeConfigurationUseCaseMock {
    struct PersonalAreaHomeMock: PersonalAreaHomeRepresentable {
        var username: String? = ""
        var isEnabledDigitalProfileView: Bool = true
        var digitalProfileInfo: PersonalAreaDigitalProfileRepresentable? = PersonalAreaDigitalProfileMock()
        var isPersonalAreaSecuritySettingEnabled: Bool = true
        var isPersonalDocOfferEnabled: Bool = true
        var isRecoveryOfferEnabled: Bool = true
    }
    
    struct PersonalAreaDigitalProfileMock: PersonalAreaDigitalProfileRepresentable {
        var digitalProfilePercentage: Double? = 30.0
        var digitalProfileType: DigitalProfileEnum? = .cadet
    }
}
