//
//  ScheduledTransferViewModel.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 05/02/2020.
//

import Foundation
import CoreFoundationLib

public protocol ScheduledTransferViewModelProtocol {
    var concept: String { get }
    var dateStartValidity: Date { get }
    var date: String? { get }
    var amountAttributedString: NSAttributedString? { get }
    var isTopSeparatorHidden: Bool { get }
    var index: Int { get }
    func setIndex(_ index: Int)
}

public final class ScheduledTransferViewModel: ScheduledTransferViewModelProtocol {
    public let entity: ScheduledTransferEntity
    public let account: AccountEntity
    private let dependenciesResolver: DependenciesResolver

    public init(_ transfer: ScheduledTransferEntity,
                account: AccountEntity,
                dependenciesResolver: DependenciesResolver) {
        self.entity = transfer
        self.account = account
        self.dependenciesResolver = dependenciesResolver
    }
    
    private(set) public var index: Int = 0
    
    private var timeManager: TimeManager {
        self.dependenciesResolver.resolve(for: TimeManager.self)
    }

    public var concept: String {
        guard let concept = entity.concept, !concept.isEmpty else {
            return localized("onePay_label_genericProgrammed")
        }
        return concept
    }

    public var dateStartValidity: Date {
        return self.entity.dateStartValidity ?? Date()
    }
    
    public var date: String? {
        return self.formattedDate()
    }

    public var amountAttributedString: NSAttributedString? {
        return self.formattedAmount()
    }
    
    private func formattedAmount() -> NSAttributedString? {
        guard let availableAmount: AmountEntity = entity.amount else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let amount = MoneyDecorator(availableAmount, font: font, decimalFontSize: 16)
        return amount.getFormatedCurrency()
    }

    private func formattedDate() -> String? {
        let formattedDate = timeManager.toString(date: self.dateStartValidity, outputFormat: .d_MMM_yyyy)
        return formattedDate
    }
    
    public var isTopSeparatorHidden: Bool {
        return self.index == 0 ? false : true
    }
    
    public func setIndex(_ index: Int) {
        self.index = index
    }
}
