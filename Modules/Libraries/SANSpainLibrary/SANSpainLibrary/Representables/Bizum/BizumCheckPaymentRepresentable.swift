//
//  CheckPayment.swift
//  SANSpainLibrary
//
//  Created by José Carlos Estela Anguita on 7/4/21.
//

import Foundation

public protocol CenterRepresentable {
    var company: String { get }
    var center: String { get }
}

public protocol BizumCheckPaymentContractRepresentable {
    var center: CenterRepresentable { get }
    var subGroup: String { get }
    var contractNumber: String { get }
}

public protocol BizumCheckPaymentIbanRepresentable {
    var country: String { get }
    var controlDigit: String { get }
    var codbban: String { get }
}

public protocol BizumCheckPaymentRepresentable {
    var phone: String { get }
    var contract: BizumCheckPaymentContractRepresentable { get }
    var initialDate: Date { get }
    var endDate: Date { get }
    var back: String? { get }
    var message: String? { get }
    var iban: BizumCheckPaymentIbanRepresentable { get }
    var offset: String? { get }
    var offsetState: String? { get }
    var indMigrad: String? { get }
    var xpan: String? { get }
}
