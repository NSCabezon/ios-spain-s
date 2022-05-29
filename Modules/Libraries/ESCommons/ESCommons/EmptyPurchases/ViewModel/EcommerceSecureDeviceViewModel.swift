//
//  EcommerceSecureDeviceViewModel.swift
//  Account
//
//  Created by Margaret López Calderón on 8/9/21.
//

import Foundation
import CoreFoundationLib

public struct EcommerceSecureDeviceViewModel {
    public let secureDeviceTitle: String
    public let secureDeviceAction: String
    public let pageStrategy: EcommerceSantanderKeyPageProtocol
    
    public init(secureDeviceTitle: String, secureDeviceAction: String, pageStrategy: EcommerceSantanderKeyPageProtocol) {
        self.secureDeviceTitle = secureDeviceTitle
        self.secureDeviceAction = secureDeviceAction
        self.pageStrategy = pageStrategy
    }
}
