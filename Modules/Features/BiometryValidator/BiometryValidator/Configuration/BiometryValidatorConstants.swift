//
//  BiometryValidatorConstants.swift
//  BiometryValidator
//
//  Created by Rubén Márquez Fernández on 18/6/21.
//

import Foundation
import CoreFoundationLib

public struct BiometryValidatorPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page: String
    public enum Action: String {
        case startsBiometrics = "starts_biometrics"
        case biometricsOK = "biometrics_OK"
        case biometricsKO = "biometrics_KO"
        case clickMoreInfo = "click_more_info"
    }
    
    public init(page: String) {
        self.page = page
    }
}
