//
//  AnalysisAreaFilterRepresentable.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 19/4/22.
//

import UI
import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

protocol AnalysisAreaFilterOutsider {
    func send(_ filters: AnalysisAreaFilterRepresentable)
}

struct DefaultAnalysisAreaFilterOutsider: AnalysisAreaFilterOutsider {
    private let subject = PassthroughSubject<AnalysisAreaFilterRepresentable, Never>()
    public var publisher: AnyPublisher<AnalysisAreaFilterRepresentable, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    public func send(_ filters: AnalysisAreaFilterRepresentable) {
        subject.send(filters)
    }
}

protocol AnalysisAreaFilterRepresentable {
    var fromDate: Date? { get set }
    var toDate: Date? { get set }
    var transactionDescription: String? { get set }
    var fromAmount: Decimal? { get set }
    var toAmount: Decimal? { get set }
    func actives() -> [ActivedFilters]
    func removeFilter(_ filter: ActivedFilters)
}

final class DefaultAnalysisAreaFilter: AnalysisAreaFilterRepresentable {
    var filters: [ActivedFilters] = [ActivedFilters]()
    var fromAmount: Decimal?
    var toAmount: Decimal?
    var fromDate: Date?
    var toDate: Date?
    var transactionDescription: String?
    
    init(fromAmount: Decimal? = nil,
         toAmount: Decimal? = nil,
         fromDate: Date? = nil,
         toDate: Date? = nil,
         description: String? = nil) {
        if let fromDate = fromDate,
            let toDate = toDate {
            self.fromDate = fromDate
            self.toDate = toDate
            self.addDateFilter(fromDate: fromDate, toDate: toDate)
        }
        self.fromAmount = fromAmount
        self.toAmount = toAmount
        self.addAmountFilter(fromAmount, toAmount: toAmount)
        if let description = description {
            self.transactionDescription = description
            self.filters.append(.byDescriptions(description))
        }
    }
    
    func actives() -> [ActivedFilters] {
        return self.filters
    }
    
    func removeFilter(_ filter: ActivedFilters) {
        self.filters.removeAll(where: { $0 == filter })
        let temp = self.filters
        switch filter {
        case .byAmount:
            self.fromAmount = nil
            self.toAmount = nil
        case .byDescriptions:
            self.transactionDescription = nil
        case .byDateRange:
            self.fromDate = nil
            self.toDate = nil
        }
        self.filters = temp
    }
}

private extension DefaultAnalysisAreaFilter {
    func addAmountFilter(_ fromAmount: Decimal?, toAmount: Decimal?) {
        self.fromAmount = fromAmount
        self.toAmount = toAmount
        var fromAmountString: String?
        var toAmountString: String?
        if let famount = self.fromAmount, let fromAmountStr = formatterForRepresentation(.transactionFilters).string(from: NSDecimalNumber(decimal: famount)) {
            fromAmountString = fromAmountStr
        }
        if let tamount = self.toAmount, let toAmountStr = formatterForRepresentation(.transactionFilters).string(from: NSDecimalNumber(decimal: tamount)) {
            toAmountString = toAmountStr
        }
        self.filters.append(.byAmount(from: fromAmountString, limit: toAmountString))
    }
    
    func addDateFilter(fromDate: Date?, toDate: Date?) {
        self.fromDate = fromDate
        self.toDate = toDate
        self.filters.append(.byDateRange(fromDate: fromDate, toDate: toDate))
    }
}
