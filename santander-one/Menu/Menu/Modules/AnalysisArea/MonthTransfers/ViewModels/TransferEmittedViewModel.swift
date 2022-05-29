//
//  TransferEmittedViewModel.swift
//  Menu
//
//  Created by David Gálvez Alonso on 08/06/2020.
//

import CoreFoundationLib

struct TransferEmittedWithColorViewModel {
    let transferEmitted: TransferEmittedViewModel
    let colorsByNameViewModel: ColorsByNameViewModel
    let highlightedText: String?
}

extension TransferEmittedWithColorViewModel: Equatable {
    static func == (lhs: TransferEmittedWithColorViewModel, rhs: TransferEmittedWithColorViewModel) -> Bool {
        let lhsValue = (lhs.transferEmitted.transfer.amountEntity.value ?? 0.0)
        let rhsValue = (rhs.transferEmitted.transfer.amountEntity.value ?? 0.0)
        guard let lhsDate = lhs.transferEmitted.transfer.executedDate,
            let rhsDate = rhs.transferEmitted.transfer.executedDate
            else { return lhsValue == rhsValue }
        return lhsDate == rhsDate && lhsValue == rhsValue
    }
}

extension TransferEmittedWithColorViewModel: Comparable {
    static func < (lhs: TransferEmittedWithColorViewModel, rhs: TransferEmittedWithColorViewModel) -> Bool {
        let lhsValue = (lhs.transferEmitted.transfer.amountEntity.value ?? 0.0)
        let rhsValue = (rhs.transferEmitted.transfer.amountEntity.value ?? 0.0)
        guard let lhsDate = lhs.transferEmitted.transfer.executedDate,
            let rhsDate = rhs.transferEmitted.transfer.executedDate,
            lhsDate != rhsDate
            else { return lhsValue  < rhsValue }
        return lhsDate < rhsDate
    }
}

public final class TransferEmittedViewModel: Equatable {
    let ibanEntity: IBANEntity?
    let transfer: TransferEntityProtocol
    private let timeManager: TimeManager
    private let baseUrl: String?
    
    init(_ ibanEntity: IBANEntity?,
         transfer: TransferEntityProtocol,
         timeManager: TimeManager,
         baseUrl: String?) {
        self.ibanEntity = ibanEntity
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
        return transfer.beneficiary?.capitalized
    }
    
    var executedDateString: String? {
        guard let date = transfer.executedDate else { return nil }
        return timeManager.toStringFromCurrentLocale(date: date, outputFormat: .dd_MMM_yyyy)?.uppercased()
    }
    
    var iban: String {
        return ibanEntity?.ibanShort(asterisksCount: 1) ?? "****"
    }
    
    var concept: String? {
        return transfer.concept
    }
    
    var transferType: KindOfTransfer {
        return transfer.transferType
    }
    
    var amount: NSAttributedString? {
        let font = UIFont.santander(family: .text, type: .bold, size: 20.0)
        
        let moneyDecorator = MoneyDecorator(transfer.amountEntity,
                                            font: font,
                                            decimalFontSize: 16.0)
        return moneyDecorator.getFormatedCurrency()
    }
    
    var bankIconUrl: String? {
        guard let entityCode = self.ibanEntity?.ibanElec.substring(4, 8) else { return nil }
        guard let baseUrl = self.baseUrl else { return nil }
        guard let contryCode = self.ibanEntity?.countryCode else { return nil }
        return String(format: "%@%@/%@_%@%@", baseUrl,
                      TransferConstant.relativeURl,
                      contryCode.lowercased(),
                      entityCode,
                      TransferConstant.iconBankExtension)
    }

    public static func == (lhs: TransferEmittedViewModel, rhs: TransferEmittedViewModel) -> Bool {
            let lhsValue = (lhs.transfer.amountEntity.value ?? 0.0)
            let rhsValue = (rhs.transfer.amountEntity.value ?? 0.0)
            guard let lhsDate = lhs.transfer.executedDate,
                let rhsDate = rhs.transfer.executedDate
                else { return lhsValue == rhsValue }
        return lhsDate == rhsDate && lhsValue == rhsValue && lhs.iban == rhs.iban
    }
}

extension TransferEmittedViewModel {
    var fullIBAN: String {
        ibanEntity?.ibanElec ?? ""
    }
}

struct TransferConstant {
    static let relativeURl = "RWD/entidades/iconos"
    static let iconBankExtension = ".png"
}
