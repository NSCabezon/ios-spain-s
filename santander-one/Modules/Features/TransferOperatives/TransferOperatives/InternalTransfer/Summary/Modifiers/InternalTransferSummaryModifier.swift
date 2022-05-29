//
//  InternalTransferSummaryModifier.swift
//  TransferOperatives
//
//  Created by Mario Rosales Maillo on 17/3/22.
//

import Foundation
import CoreDomain

public protocol InternalTransferSummaryModifierProtocol {
    var additionalFeeKey: String { get }
    var additionalFeeLinkKey: String? { get }
    var additionalFeeLink: String? { get }
    var additionalFeeIconKey: String { get }
    func freeTransferFor(originAccount: AccountRepresentable, destinationAccount: AccountRepresentable, date: Date) -> Bool
}

final class DefaultInternalTransferSummaryModifier : InternalTransferSummaryModifierProtocol {
    var additionalFeeKey: String = "confirmation_label_additionalFee"
    var additionalFeeLinkKey: String? = "confirmation_label_seeFeeCharges"
    var additionalFeeLink: String? = ""
    var additionalFeeIconKey: String = "icnInfo"
    func freeTransferFor(originAccount: AccountRepresentable, destinationAccount: AccountRepresentable, date: Date) -> Bool {
        return date.isDayInToday()
    }
}
