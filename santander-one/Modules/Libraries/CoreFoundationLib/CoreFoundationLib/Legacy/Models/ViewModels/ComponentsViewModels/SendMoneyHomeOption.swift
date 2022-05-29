//
//  SendMoneyHomeOption.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 24/11/21.
//

import Foundation
import CoreDomain

public enum SendMoneyHomeActionType {
    case transfer
    case transferBetweenAccounts
    case atm
    case scheduleTransfers
    case donations(OfferRepresentable?)
    case custom(identifier: String, title: String, description: String, icon: String, offer: OfferRepresentable?)
    case reuse(IBANRepresentable, String)
    
    public func values() -> (title: String, imageName: String, description: String) {
        switch self {
        case .transfer, .reuse(_, _):
            return ("transferOption_button_transfer",
                    "oneIcnTransferRed",
                    "transferOption_text_transfer")
        case .transferBetweenAccounts:
            return ("transferOption_button_transferAccount",
                    "oneIcnTransactions",
                    "transferOption_text_transferAccount")
        case .atm:
            return ("transferOption_button_atm",
                    "icnSendAtm",
                    "transferOption_text_atm")
        case .scheduleTransfers:
            return ("transferOption_button_periodic",
                    "oneIcnRefresh",
                    "transferOption_text_periodic")
        case .donations:
            return ("transferOption_button_donations",
                    "oneIcnDonations",
                    "transferOption_text_donations")
        case let .custom(_, title, description, icon, _):
            return (title, icon, description)
        }
    }
}

extension SendMoneyHomeActionType {
    public var accessibilityIdentifier: String? {
        switch self {
        case .transfer:
            return "sendMoneyHomeViewTransferActionView"
        case .reuse:
            return "sendMoneyHomeViewReuseActionView"
        case .transferBetweenAccounts:
            return "sendMoneyHomeViewSwitchActionView"
        case .atm:
            return "sendMoneyHomeViewAtmActionView"
        case .scheduleTransfers:
            return "sendMoneyHomeViewScheduleTransfersActionView"
        case .donations:
            return "sendMoneyHomeViewDonationsActionView"
        case .custom(let identifier, _, _, _, _):
            return identifier
        }
    }
        
    public static func custom(identifier: String, title: String, description: String, icon: String) -> SendMoneyHomeActionType {
        return .custom(identifier: identifier, title: title, description: description, icon: icon, offer: nil)
    }
}

public class SendMoneyHomeOption {
    public var title: String
    public var description: String
    public var imageName: String
    public var actionType: SendMoneyHomeActionType
    public var action: ((SendMoneyHomeActionType) -> Void)?
    public let accessibilityIdentifier: String?
    public init(title: String,
                description: String,
                imageName: String,
                actionType: SendMoneyHomeActionType,
                action: ((SendMoneyHomeActionType) -> Void)?) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.action = action
        self.accessibilityIdentifier = actionType.accessibilityIdentifier
        self.actionType = actionType
    }
}
