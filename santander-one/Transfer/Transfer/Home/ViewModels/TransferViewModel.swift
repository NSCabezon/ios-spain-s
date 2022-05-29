//
//  TransferEmittedViewModel.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/23/19.
//

import Foundation
import CoreFoundationLib

struct TransferEmittedWithColorViewModel {
    let viewModel: TransferViewModel
    let colorsByNameViewModel: ColorsByNameViewModel
    let highlightedText: String?
}

public final class TransferViewModel {
    public var from: AccountEntity?
    public let account: AccountEntity
    public let transfer: TransferEntityProtocol
    private let timeManager: TimeManager
    public let baseUrl: String?
    
    public var instantPaymentId: String? { transfer.instantPaymentId }
    
    public init(
        _ account: AccountEntity,
        transfer: TransferEntityProtocol,
        timeManager: TimeManager,
        baseUrl: String?
    ) {
        self.account = account
        self.transfer = transfer
        self.timeManager = timeManager
        self.baseUrl = baseUrl
    }
    
    var executedDate: Date? {
        return transfer.executedDate
    }
    
    var avatarName: String {
        return self.beneficiary?
            .split(" ")
            .prefix(2)
            .map({ $0.prefix(1) })
            .joined()
            .uppercased() ?? ""
    }
    
    var beneficiary: String? {
        return transfer.beneficiary?.capitalizedIgnoringNumbers()
    }
    
    var executedDateString: String? {
        guard let date = transfer.executedDate else { return nil }
        return timeManager.toStringFromCurrentLocale(date: date, outputFormat: .dd_MMM_yy)?.uppercased()
    }
    
    var iban: String? {
        return account.getIBANShort
    }
    
    var concept: String? {
        return transfer.concept
    }
    
    var transferType: KindOfTransfer {
        return transfer.transferType
    }
    
    var amount: NSAttributedString? {
        let font = UIFont.santander(family: .text, type: .bold, size: 20.0)
        
        let moneyDecorator = MoneyDecorator(transferType == .emitted ? transfer.amountEntity.changedSign : transfer.amountEntity,
                                            font: font,
                                            decimalFontSize: 16.0)
        return moneyDecorator.getFormatedCurrency()
    }
    
    var amountSmallFont: NSAttributedString? {
        let font = UIFont.santander(family: .text, type: .bold, size: 16.0)
        
        let moneyDecorator = MoneyDecorator(transferType == .emitted ? transfer.amountEntity.changedSign : transfer.amountEntity,
                                            font: font,
                                            decimalFontSize: 13.0)
        return moneyDecorator.getFormatedCurrency()
    }
    
    public var bankIconUrl: String? {
        guard let entityCode = self.account.getIban()?.ibanElec.substring(4, 8) else { return nil }
        guard let contryCode = self.account.contryCode else { return nil }
        guard let baseUrl = self.baseUrl else { return nil }
        return String(format: "%@%@/%@_%@%@", baseUrl,
                      GenericConstants.relativeURl,
                      contryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
}

extension TransferEmittedWithColorViewModel: Equatable {
    static func == (lhs: TransferEmittedWithColorViewModel, rhs: TransferEmittedWithColorViewModel) -> Bool {
        return lhs.viewModel == rhs.viewModel
    }
}

extension TransferEmittedWithColorViewModel: Comparable {
    static func < (lhs: TransferEmittedWithColorViewModel, rhs: TransferEmittedWithColorViewModel) -> Bool {
        return lhs.viewModel < rhs.viewModel
    }
}

extension TransferViewModel: Equatable {
    public static func == (lhs: TransferViewModel, rhs: TransferViewModel) -> Bool {
        let lhsValue = (lhs.transfer.amountEntity.value ?? 0.0)
        let rhsValue = (rhs.transfer.amountEntity.value ?? 0.0)
        guard let lhsDate = lhs.transfer.executedDate,
              let rhsDate = rhs.transfer.executedDate
        else { return lhsValue == rhsValue }
        return lhsDate == rhsDate && lhsValue == rhsValue
    }
}

extension TransferViewModel: Comparable {
    public static func < (lhs: TransferViewModel, rhs: TransferViewModel) -> Bool {
        let lhsValue = (lhs.transfer.amountEntity.value ?? 0.0)
        let rhsValue = (rhs.transfer.amountEntity.value ?? 0.0)
        guard let lhsDate = lhs.transfer.executedDate,
              let rhsDate = rhs.transfer.executedDate,
              lhsDate != rhsDate
        else {
            guard lhsValue == rhsValue else { return lhsValue < rhsValue }
            return (lhs.beneficiary ?? "") > (rhs.beneficiary ?? "")
        }
        return lhsDate < rhsDate
    }
}
