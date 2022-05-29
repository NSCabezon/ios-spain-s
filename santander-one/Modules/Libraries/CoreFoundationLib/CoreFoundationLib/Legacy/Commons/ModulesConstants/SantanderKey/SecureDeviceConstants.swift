//
//  SecureDeviceLoginPage.swift
//  Account
//
//  Created by Margaret López Calderón on 9/9/21.
//

import Foundation

public struct SecureDeviceLoginPage: PageWithActionTrackable {
    public let page = "/san_key_with_safe_device"
    public enum Action {
        public static let updateSecureDevice = "update_safe_device"
        public static let cancelUpdateSecureDevice = "update_not_now"
    }
    
    public init() {}
}

public struct SecureDeviceConstants {
    public static let tutorial = "SCA_ECOMMERCE_SECURE_DEVICE_TUTORIAL"
}

public struct NotRegisteredSecureDeviceLoginPage: PageWithActionTrackable {
    public let page = "/san_key_without_safe_device"
    public enum Action {
        public static let cancelRegisterSecureDevice = "register_not_now"
        public static let registerSecureDevice = "register_safe_device"
    }
    
    public init() {}
}
