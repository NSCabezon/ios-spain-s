//
//  TransferActionViewModel.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/18/19.
//

import Foundation
import CoreFoundationLib
import UI

public enum TransferActionType {
    case transfer
    case transferBetweenAccounts
    case onePayFX(OfferEntity?)
    case atm
    case correosCash(OfferEntity?)
    case scheduleTransfers
    case donations(OfferEntity?)
    case custome(identifier: String, title: String, description: String, icon: String)
    case reuse(IBANEntity, String)
    
    struct TransferActionTypeConfiguration {
        let title: String
        let imageName: String
        let description: String
    }
    
    func values() -> TransferActionTypeConfiguration {
        switch self {
        case .transfer, .reuse:
            return TransferActionTypeConfiguration(title: "transferOption_button_transfer",
                                                   imageName: "icnTransfer",
                                                   description: "transferOption_text_transfer")
        case .correosCash:
            return TransferActionTypeConfiguration(title: "transferOption_button_correosCash",
                                                   imageName: "icnCorreosCash",
                                                   description: "transferOption_text_correosCash")
        case .transferBetweenAccounts:
            return TransferActionTypeConfiguration(title: "transferOption_button_transferAccount",
                                                   imageName: "icnTransferAccountsRed",
                                                   description: "transferOption_text_transferAccount")
        case .onePayFX:
            return TransferActionTypeConfiguration(title: "transferOption_button_onePay",
                                                   imageName: "icnOnePay",
                                                   description: "transferOption_text_onePay")
        case .atm:
            return TransferActionTypeConfiguration(title: "transferOption_button_atm",
                                                   imageName: "icnSendAtm",
                                                   description: "transferOption_text_atm")
        case .scheduleTransfers:
            return TransferActionTypeConfiguration(title: "transferOption_button_periodic",
                                                   imageName: "icnSendProgrammed",
                                                   description: "transferOption_text_periodic")
        case .donations:
            return TransferActionTypeConfiguration(title: "transferOption_button_donations",
                                                   imageName: "icnDonationsBig",
                                                   description: "transferOption_text_donations")
        case let .custome(_, title, description, icon):
            return TransferActionTypeConfiguration(title: title,
                                                   imageName: icon,
                                                   description: description)
        }
    }
}

extension TransferActionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .transfer:
            return AccessibilityTransferHome.sendMoneyHomeViewTransferActionView
        case .reuse:
            return AccessibilityTransferHome.sendMoneyHomeViewReuseActionView
        case .transferBetweenAccounts:
            return AccessibilityTransferHome.sendMoneyHomeViewSwitchActionView
        case .onePayFX:
            return AccessibilityTransferHome.sendMoneyHomeViewOnePayFxActionView
        case .atm:
            return AccessibilityTransferHome.sendMoneyHomeViewAtmActionView
        case .correosCash:
            return AccessibilityTransferHome.sendMoneyHomeViewCorreosCashActionView
        case .scheduleTransfers:
            return AccessibilityTransferHome.sendMoneyHomeViewScheduleTransfersActionView
        case .donations:
            return AccessibilityTransferHome.sendMoneyHomeViewDonationsActionView
        case .custome(let identifier, _, _, _):
            return identifier
        }
    }
}

final class TransferActionViewModel {
    var title: String
    var description: String
    var imageName: String
    var actionType: TransferActionType
    var action: ((TransferActionType) -> Void)?
    let accessibilityIdentifier: String?
    init(title: String,
         description: String,
         imageName: String,
         actionType: TransferActionType,
         action: ((TransferActionType) -> Void)?) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.action = action
        self.accessibilityIdentifier = actionType.accessibilityIdentifier
        self.actionType = actionType
    }
}

enum TransferActionOrigin {
    case home, curtain
}
