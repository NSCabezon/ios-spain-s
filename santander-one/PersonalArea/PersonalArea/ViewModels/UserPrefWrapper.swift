//
//  UserPrefWrapper.swift
//  PersonalArea
//
//  Created by alvola on 13/08/2020.
//

import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

public final class UserPrefWrapper {
    var username: String?
    var userNameWithoutSurname: String?
    var userCompleteName: String?
    var userAlias: String?
    var isNotificationEnable: Bool?
    var currentPhotoTheme: Int?
    var currentPG: Int?
    var currentLanguage: LanguageType?
    var isDiscretModeActivated: Bool?
    var isChartModeActivated: Bool?
    public var isOperativeUser: Bool?
    public var isGeolocalizationEnabled: Bool?
    var isAuthEnabled: Bool?
    var isKeychainBiometryEnabled: Bool?
    public var biometryType: BiometryTypeEntity?
    var biometryError: BiometryErrorEntity?
    var isEnabledDigitalProfileView: Bool?
    var isPersonalAreaSecuritySettingEnabled: Bool?
    var isAppInfoEnabled: Bool?
    var digitalProfilePercentage: Double?
    var digitalProfileType: DigitalProfileEnum?
    var personalInfo: PersonalInfoWrapper?
    var editPersonalInfoEnabled: Bool?
    var editDNIEnabled: Bool?
    public var manageGDPR: Bool?
    var userPrefEntity: UserPrefEntity?
    var isPersonalAreaEnabled: Bool?
    var isPersonalDocEnabled: Bool?
    var isPersonalDocOfferEnabled: Bool?
    var isConfigureAlertsEnabled: Bool?
    var isPhoneConfigured: Bool? {
        return userPrefEntity?.isPhoneConfigured()
    }
    var isEmailConfigured: Bool? {
        return userPrefEntity?.isEmailConfigured()
    }
    public var isOtpPushEnabled: Bool?
    var isRecoveryOfferEnabled: Bool?
    public var lastAccessInfo: LastLogonViewModel?
    var loginType: String?
    public var isUserLoginType: Bool {
        self.loginType == UserLoginType.U.type
    }
    public var isValidPhone: Bool {
        return !(self.personalInfo?.phone ?? "").isEmpty
    }
    public var isValidEmail: Bool {
        return !(self.personalInfo?.email ?? "").isEmpty
    }
}
