//
//  BiometryValidatorConfiguration.swift
//  BiometryValidator
//
//  Created by Rubén Márquez Fernández on 21/5/21.
//

import Foundation

public enum BiometryValidatorStatus {
    case confirm
    case error
    case identifying
    
    func titleText() -> String {
        switch self {
        case .confirm:
            return "generic_button_confirm"
        case .error:
            return "ecommerce_button_useElectronicSignature"
        case .identifying:
            return "ecommerce_button_identifying"
        }
    }
}

public enum BiometryValidatorAuthType {
    case fingerPrint
    case faceId
    
    func imageName() -> String {
        switch self {
        case .fingerPrint:
            return "icnEcommerceTouchId"
        case .faceId:
            return "icnBigFaceId"
        }
    }
    
    func smallImageName() -> String {
        switch self {
        case .fingerPrint:
            return "icnEcommerceTouchIdWhiteSmall"
        case .faceId:
            return "icnEcommerceFaceIdWhiteSmall"
        }
    }
    
    func titleText() -> String {
        switch self {
        case .fingerPrint:
            return "ecommerce_label_confirmFingerPrint"
        case .faceId:
            return "ecommerce_label_confirmFaceId"
        }
    }
    
    func errorText() -> String {
        switch self {
        case .fingerPrint:
            return "ecommerce_label_ErrorFingerPrint"
        case .faceId:
            return "ecommerce_label_errorFacial"
        }
    }
}
