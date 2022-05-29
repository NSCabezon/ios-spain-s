//
//  MockGetPersonalAreaHomeConfigurationUseCase.swift
//  PersonalArea-Unit-Tests
//
//  Created by alvola on 20/4/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import OpenCombine
import PersonalArea
import CoreTestData

struct MockGetPersonalAreaHomeConfigurationUseCase: GetPersonalAreaHomeConfigurationUseCase {
    let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func fetchPersonalAreaHomeConfiguration() -> AnyPublisher<PersonalAreaHomeRepresentable, Never> {
        let isPersonalAreaSecuritySettingEnabled = self.mockDataInjector
            .mockDataProvider
            .appConfigLocalData
            .getAppConfigLocalData
            .defaultConfig?[PersonalAreaConstants.isPersonalAreaSecuritySettingEnabled] == "true"
        return Just(PersonalAreaHomeMock(isPersonalAreaSecuritySettingEnabled: isPersonalAreaSecuritySettingEnabled)).eraseToAnyPublisher()
    }
}

struct PersonalAreaHomeMock: PersonalAreaHomeRepresentable {
    var isEnabledDigitalProfileView: Bool = true
    var digitalProfileInfo: PersonalAreaDigitalProfileRepresentable?
    var isPersonalAreaSecuritySettingEnabled: Bool = true
    var isPersonalDocOfferEnabled: Bool = true
    var isRecoveryOfferEnabled: Bool = true
    
    init(isEnabledDigitalProfileView: Bool = true,
         digitalProfileInfo: PersonalAreaDigitalProfileRepresentable? = nil,
         isPersonalAreaSecuritySettingEnabled: Bool = true,
         isPersonalDocOfferEnabled: Bool = true,
         isRecoveryOfferEnabled: Bool = true) {
        self.isEnabledDigitalProfileView = isEnabledDigitalProfileView
        self.digitalProfileInfo = digitalProfileInfo
        self.isPersonalAreaSecuritySettingEnabled = isPersonalAreaSecuritySettingEnabled
        self.isPersonalDocOfferEnabled = isPersonalDocOfferEnabled
        self.isRecoveryOfferEnabled = isRecoveryOfferEnabled
    }
}
