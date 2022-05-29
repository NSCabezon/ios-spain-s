//
//  SpainTransferType.swift
//  Santander
//
//  Created by Angel Abad Perez on 25/11/21.
//

import CoreFoundationLib

enum SpainTransferType: String, SendMoneyTransferTypeProtocol {
    case standard = "STANDARD"
    case immediate = "INSTANT"
    case urgent = "URGENT"
    
    public var serviceString: String {
        switch self {
        case .standard:
            return "N"
        case .immediate:
            return "I"
        case .urgent:
            return "S"
        }
    }
    
    var title: String? {
        switch self {
        case .standard:
            return "sendMoney_label_standardSent"
        case .immediate:
            return "sendMoney_label_immediateSend"
        case .urgent:
            return "sendMoney_label_expressDelivery"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .standard:
            return "sendType_text_standar"
        case .immediate:
            return "sendType_text_inmediate"
        case .urgent:
            return "sendType_text_express"
        }
    }
    
    var commissionsInfo: String? {
        switch self {
        case .standard:
            return "sendMoney_label_variableCost"
        case .immediate:
            return "sendMoney_label_costServices"
        case .urgent:
            return "sendMoney_label_service"
        }
    }
    
    var costViewTitle: String? {
        switch self {
        case .standard:
            return "sendMoney_label_standardSent"
        case .immediate:
            return "sendMoney_label_immediateSend"
        case .urgent:
            return "sendMoney_label_expressDelivery"
        }
    }
    
    var costViewSubtitle: String? {
        switch self {
        case .standard:
            return "sendType_tooltip_standar"
        case .immediate:
            return "sendType_tooltip_inmediate"
        case .urgent:
            return "sendType_tooltip_express"
        }
    }
    
    var costViewSelectButton: String {
        switch self {
        case .standard:
            return "voiceover_button_selectStandard"
        case .immediate:
            return "voiceover_button_selectImmediate"
        case .urgent:
            return "voiceover_button_selectExpress"
        }
    }
    
    init? (fromServiceString string: String) {
        switch string {
        case "N": self = .standard
        case "I": self = .immediate
        case "S": self = .urgent
        default: return nil
        }
    }
}
