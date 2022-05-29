//
//  SpainInternationalTransferType.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 17/2/22.
//

import CoreFoundationLib

enum SpainInternationalTransferType: String, SendMoneyTransferTypeProtocol {
    case standard
    
    var serviceString: String {
        switch self {
        case .standard: return "N"
        }
    }
    
    var title: String? {
        switch self {
        case .standard: return "confirmation_label_internacionalStandardFee"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .standard: return "sendType_text_standar"
        }
    }
}
