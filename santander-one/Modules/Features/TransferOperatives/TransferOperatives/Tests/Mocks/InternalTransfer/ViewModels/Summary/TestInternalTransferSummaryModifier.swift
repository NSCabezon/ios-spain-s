//
//  TestInternalTransferSummaryModifier.swift
//  TransferOperatives-Unit-Tests
//
//  Created by Mario Rosales Maillo on 28/3/22.
//

import Foundation
@testable import TransferOperatives
import CoreFoundationLib
import CoreDomain

class TestInternalTransferSummaryModifier: InternalTransferSummaryModifierProtocol {
    public var additionalFeeKey: String = "pl_summary_label_commissionsPercentage"
    public var additionalFeeLinkKey: String? = "summary_label_seeFeeCharges"
    public var additionalFeeLink: String? = "http://www.mock.link"
    public var additionalFeeIconKey: String = "icnInfo"
    public var isFreeTransferShouldReturn: Bool = false
    
    func freeTransferFor(originAccount: AccountRepresentable, destinationAccount: AccountRepresentable, date: Date) -> Bool {
        return isFreeTransferShouldReturn
    }
}
