//
//  SplitTransactionContactViewModel.swift
//  Bizum

import CoreFoundationLib
import UI

struct SplitTransactionContactViewModel {
    let identifier: String?
    let initials: String?
    let name: String?
    let phone: String
    let colorModel: ColorsByNameViewModel?
    let tag: Int?
    var splittedAmount: AmountEntity
    var splittedAmountFormatted: NSAttributedString?
    let isDeviceUser: Bool
    var showPlainSeparatorView: Bool
    let thumbnailData: Data?

    init(identifier: String?,
         initials: String?,
         name: String?,
         phone: String,
         colorModel: ColorsByNameViewModel? = nil,
         tag: Int? = nil,
         splittedAmount: AmountEntity,
         isDeviceUser: Bool = false,
         showPlainSeparatorView: Bool = false,
         thumbnailData: Data?) {
        self.identifier = identifier
        self.initials = initials
        self.name = name
        self.phone = phone
        self.colorModel = colorModel
        self.tag = tag
        self.splittedAmount = splittedAmount
        self.splittedAmountFormatted = SplitTransactionContactViewModel.formatAmount(splittedAmount)
        self.isDeviceUser = isDeviceUser
        self.showPlainSeparatorView = showPlainSeparatorView
        self.thumbnailData = thumbnailData
    }
    
    var isPhoneHidden: Bool {
        guard !self.isDeviceUser else { return true }
        return self.phone.isEmpty
    }
}

extension SplitTransactionContactViewModel {
    mutating func updateSplittedAmount(_ newAmount: AmountEntity) {
        splittedAmount = newAmount
        self.splittedAmountFormatted = SplitTransactionContactViewModel.formatAmount(newAmount)
    }
    
    mutating func showPlainSeparator() {
        self.showPlainSeparatorView = true
    }
    
    mutating func showDottedSeparator() {
        self.showPlainSeparatorView = false
    }
    
    private static func formatAmount(_ amount: AmountEntity) -> NSAttributedString? {
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .regular, size: 17), decimalFontSize: 17)
        return moneyDecorator.getFormatedCurrency()
    }
}

extension SplitTransactionContactViewModel: Hashable {
    static func == (lhs: SplitTransactionContactViewModel, rhs: SplitTransactionContactViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var hashValue: Int {
        if let identifier = identifier, let hash = Int(identifier) {
            return hash
        }
        return 0
    }
}
