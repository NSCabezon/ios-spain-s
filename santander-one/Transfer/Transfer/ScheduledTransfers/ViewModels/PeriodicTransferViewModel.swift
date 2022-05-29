//
//  PeriodicTransferViewModel.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 2/10/20.
//

import Foundation
import CoreFoundationLib

public protocol PeriodicTransferViewModelProtocol {
    var concept: String { get }
    var dateStartValidity: Date { get }
    var dateDescription: LocalizedStylableText? { get }
    var amountAttributedString: NSAttributedString? { get }
    var isTopSeparatorHidden: Bool { get }
    var index: Int { get }
    func setIndex(_ index: Int)
}

public final class PeriodicTransferViewModel: PeriodicTransferViewModelProtocol {
    public let entity: ScheduledTransferEntity
    public let account: AccountEntity
    private let dependenciesResolver: DependenciesResolver
    
    public init(_ entity: ScheduledTransferEntity,
                account: AccountEntity,
                dependenciesResolver: DependenciesResolver) {
        self.entity = entity
        self.account = account
        self.dependenciesResolver = dependenciesResolver
    }
    
    private(set) public var index: Int = 0
    
    private var timeManager: TimeManager {
        self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    public var concept: String {
        guard let concept = entity.concept, !concept.isEmpty else {
            return localized("onePay_label_genericPeriodic")
        }
        return concept
    }
    
    public var dateStartValidity: Date {
        return self.entity.dateStartValidity ?? Date()
    }

    public var dateDescription: LocalizedStylableText? {
        return self.formattedDescription()
    }

    public var amountAttributedString: NSAttributedString? {
        guard let availableAmount: AmountEntity = entity.amount else { return nil }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let amount = MoneyDecorator(availableAmount, font: font, decimalFontSize: 16)
        return amount.getFormatedCurrency()
    }
    
    private func formattedDescription() -> LocalizedStylableText? {
        guard let day = timeManager.toString(date: self.dateStartValidity, outputFormat: .d)  else { return nil }
        guard let periodicity = entity.periodicalType else { return nil }
        var localizableText: LocalizedStylableText?
        switch periodicity {
        case .monthly:
            localizableText = localized("transfer_label_monthlyPeriodic", [StringPlaceholder(.number, day)])
        case .trimestral:
            localizableText = localized("transfer_label_trimesterPeriodic", [StringPlaceholder(.number, day)])
        case .semiannual:
            localizableText = localized("transfer_label_biannualPeriodic", [StringPlaceholder(.number, day)])
        }
        return localizableText
    }
    
    public var isTopSeparatorHidden: Bool {
        return self.index == 0 ? false : true
    }
    
    public func setIndex(_ index: Int) {
        self.index = index
    }
}
