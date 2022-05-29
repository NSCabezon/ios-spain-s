//
//  EcommerceConstants.swift
//  Commons
//
//  Created by Ignacio González Miró on 11/3/21.
//

public struct EcommercePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "santander_key"
    public enum Action: String {
        case knowMoreButton = "saber_mas"
        case confirmKeyAccessOk = "confirmacion_clave_acceso_ok"
        case confirmKeyAccessError = "confirmacion_clave_acceso_error"
        case confirmBiometryOk = "confirmacion_biometria"
        case confirmBiometryError = "confirmacion_biometria_error"
    }
    public init() {}
}

public struct EcommerceConstants {
    public static let publicTutorial = "SCA_ECOMMERCE_PUBLIC_TUTORIAL"
    public static let privateTutorial = "SCA_ECOMMERCE_PRIVATE_TUTORIAL"
    public static let enableEcommerceAppConfig = "enableEcommerce"
}

// MARK: Secure device
public enum EcommerceSecureDeviceStatus {
    case register
    case update
}

public protocol EcommerceSantanderKeyPageProtocol {
    var page: String { get }
    var statusSecureDevice: EcommerceSecureDeviceStatus { get }
}

public struct EcommerceSantanderKeyPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page: String
    public let strategy: EcommerceSantanderKeyPageProtocol?
    
    public enum Action: String {
        case registerButton = "register_safe_device"
        case updateButton = "update_safe_device"
    }
    
    public init(strategy: EcommerceSantanderKeyPageProtocol? = nil) {
        self.strategy = strategy
        self.page = strategy?.page ?? ""
    }
}

public struct EcommerceRegisterSantanderKeyLoginRememberPage: EcommerceSantanderKeyPageProtocol {
    public var statusSecureDevice: EcommerceSecureDeviceStatus = .register
    public let page = "/SCA_san_key_KU_without_SD"
    
    public init() {}
}

public struct EcommerceRegisterSantanderKeyPGPage: EcommerceSantanderKeyPageProtocol {
    public var statusSecureDevice: EcommerceSecureDeviceStatus = .register
    public let page = "/SCA_san_key_pg_notifications_without_SD"
    
    public init() {}
}

public struct EcommerceUpdateSantanderKeyPGPage: EcommerceSantanderKeyPageProtocol {
    public var statusSecureDevice: EcommerceSecureDeviceStatus = .update
    public let page = "/SCA_san_key_pg_notifications_update_SD"
    
    public init() {}
}
