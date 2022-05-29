//
//  DeleteScheduledTransferOperativeData.swift
//  Transfer
//
//  Created by Boris Chirino Fernandez on 20/7/21.
//

import CoreFoundationLib

final class DeleteScheduledTransferOperativeData {
    var order: ScheduledTransferRepresentable?
    var account: AccountEntity?
    var detail: ScheduledTransferDetailEntity?
    var sepaInfoList: SepaInfoListEntity?
    var originAccountAlias: String?
    var bankIconURL: String?
}
