//
//  NoSepaTransferRepresentable.swift
//  SANSpainLibrary
//
//  Created by José María Jiménez Pérez on 16/2/22.
//

import CoreDomain

public protocol NoSepaTransferRepresentable {
    var countryCode: String? { get }
    var countryName: String? { get }
    var bicSwift: String? { get }
    var amountRepresentable: AmountRepresentable? { get }
    var destinationAccount: String? { get }
    var bankName: String? { get }
    var bankAddress: String? { get }
}
