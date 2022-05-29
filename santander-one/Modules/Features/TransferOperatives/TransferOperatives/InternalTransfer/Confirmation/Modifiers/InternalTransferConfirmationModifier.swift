//
//  InternalTransferConfirmationModifier.swift
//  TransferOperatives
//
//  Created by Juan Sánchez Marín on 22/3/22.
//

import Foundation
import CoreDomain

public protocol InternalTransferConfirmationModifierProtocol {
    var additionalFeeKey: String { get }
    var additionalFeeLinkKey: String? { get }
    var additionalFeeLink: String? { get }
    var additionalFeeIconKey: String { get }
    func freeTransferFor(originAccount: AccountRepresentable, destinationAccount: AccountRepresentable, date: Date) -> Bool
}

final class DefaultInternalTransferConfirmationModifier: InternalTransferConfirmationModifierProtocol {
    var additionalFeeKey: String = "confirmation_label_additionalFee"
    var additionalFeeLinkKey: String? = "confirmation_label_seeFeeCharges"
    var additionalFeeLink: String? = ""
    var additionalFeeIconKey: String = "icnInfo"
    func freeTransferFor(originAccount: AccountRepresentable, destinationAccount: AccountRepresentable, date: Date) -> Bool {
        return date.isDayInToday()
    }
}
