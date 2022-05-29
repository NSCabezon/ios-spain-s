//
//  UpdateCompaniesOutsiders.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 24/3/22.
//

import Foundation
import CoreDomain
import OpenCombine

public protocol UpdateCompaniesOutsider {
    func send(_: GetUpdateCompaniesOutsiderSubject)
}

struct DefaultUpdateCompaniesOutsider: UpdateCompaniesOutsider {
    private let subject = PassthroughSubject<GetUpdateCompaniesOutsiderSubject, Never>()
    public var publisher: AnyPublisher<GetUpdateCompaniesOutsiderSubject, Never>
    
    init() {
        publisher = subject.eraseToAnyPublisher()
    }
    
    public func send(_ input: GetUpdateCompaniesOutsiderSubject) {
        switch input {
        case .void:
            subject.send(.void)
        case .data(let data):
            subject.send(.data(data))
        }
    }
}

public enum GetUpdateCompaniesOutsiderSubject {
    case void
    case data(GetUpdateCompaniesOutsiderRepresentable)
}

public struct GetUpdateCompaniesOutsiderRepresentable {
    var selectedProducts: [FinancialHealthProductRepresentable] = []
    var companies: [FinancialHealthCompanyRepresentable] = []
    var companiesWithProductsSelected: [FinancialHealthCompanyRepresentable] = []
    var accountsSelected: Int = 0
    var cardsSelected: Int = 0
    var showUpdateError: Bool = false
    var showNetworkError: Bool = false
    var productsStatus: FinancialHealthProductsStatusRepresentable? = nil
    var summary: [FinancialHealthSummaryItemRepresentable] = []
}
