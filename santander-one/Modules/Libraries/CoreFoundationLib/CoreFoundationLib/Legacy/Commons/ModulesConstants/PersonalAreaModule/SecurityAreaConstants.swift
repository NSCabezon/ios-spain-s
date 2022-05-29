
public struct SecurityAreaPullOffers {
    public static let contact = "DATOS_CONTACTO"
    public static let deviceSecurityVideo = "SECURE_DEVICE_TUTORIAL_VIDEO"
    public static let personalAreaAlert = "AREA_PERSONAL_ALERTAS_SSC"
    public static let thirtPartyPermissions = "PERMISOS_TERCEROS"
    public static let onlineProtection = "SEGURIDAD_PROTECCION_ONLINE"
    public static let safeBoxSecurity = "SEGURIDAD_CAJA_FUERTE"
    public static let safeBoxSecurityNoOne = "SEGURIDAD_CAJA_FUERTE_NO_ONE"
}

public struct SecurityAreaPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/security"
    
    public enum Action: String {
        case fraud = "report_fraud"
        case stole = "report_robbery"
        case trips = "click_travel_mode"
        case otpPush = "click_secure_device"
        case permissions = "manage_third_permission"
        case biometricOn = "unlock_biometric"
        case biometricError = "error_{step1_step2}"
        case biometricOff = "lock_biometric"
        case geolocationOn = "unlock_geolocation"
        case geolocationOff = "lock_geolocation"
        case user = "click_user_type"
        case quickBalanceOn = "unlock_quick_balance"
        case quickBalanceOff = "lock_quick_balance"
        case accessKey = "click_password_digital_signature"
        case multichannelSign = "click_digital_signature"
        case swipe = "swipe_security_tip"
    }
    public init() {}
}

public struct SecurityModulePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/personal_area/security"
    
    public enum Action: String {
        case biometricOn = "unlock_biometric"
        case error = "lock_notification"
        case biometricOff = "lock_biometric"
        case geolocationOn = "unlock_geolocation"
        case geolocationOff = "lock_geolocation"
        case secureDevice = "unlock_secure_device"
        case quickBalanceOn = "unlock_quick_balace"
        case quickBalanceOff = "lock_quick_balance"
        case user = "click_user"
        case accessKey = "click_password_signature"
        case consents = "click_consent"
    }
    public init() {}
}

public struct SecurityAreaOtpPushPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "area_personal_seguridad_otp_push"
    
    public enum Action: String {
        case register = "registro"
        case actualDevice = "dispositivo_actual"
    }
    public init() {}
}

public struct SecurityAreaOtpPushAliasPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "area_personal_seguridad_otp_push_alias"
    
    public enum Action: String {
        case save = "guardar"
    }
    public init() {}
}

public struct SecurityAreaOtpPushSignaturePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "area_personal_seguridad_otp_push_firma"
    
    public enum Action: String {
        case error
    }
    public init() {}
}

public struct SecurityAreaOtpPushOtpPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "area_personal_seguridad_otp_push_otp"
    
    public enum Action: String {
        case error
    }
    public init() {}
}

public struct SecurityAreaOtpPushResumePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "area_personal_seguridad_otp_push_resumen"
    
    public enum Action: String {
        case help = "ayudanos_a_mejorar"
        case globalPosition = "posicion_global"
    }
    public init() {}
}

public struct OperabilitySelectorPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "cambio_operatividad"
    
    public enum Action: String {
        case next = "cambio_tipo"
        case error = "error"
    }
    public init() {}
}

public struct OperabilitySignaturePage: PageTrackable {
    public let page = "cambio_operatividad_firma"
    public init() {}
}

public struct OperabilityOTPPage: PageTrackable {
    public let page = "cambio_operatividad_otp"
    public init() {}
}

public struct OperabilitySummaryPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "cambio_operatividad_resumen"
    
    public enum Action: String {
        case opinator = "ayudanos_a_mejorar"
    }
    public init() {}
}
