//
//  SPNoSepaPayeeDetailRepresentable.swift
//  SANSpainLibrary
//
//  Created by José María Jiménez Pérez on 16/2/22.
//

import CoreDomain

public protocol SPNoSepaPayeeDetailRepresentable: NoSepaPayeeDetailRepresentable {
    var amountRepresentable: AmountRepresentable? { get }
    var countryCode: String? { get }
    var bankName: String? { get }
    var bankAddress: String? { get }
    var bicSwift: String? { get }
    var destinationAccount: String? { get }
}
