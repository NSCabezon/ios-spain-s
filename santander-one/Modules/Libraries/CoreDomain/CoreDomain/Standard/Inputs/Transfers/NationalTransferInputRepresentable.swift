//
//  NationalTransferInputRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 19/08/2021.
//

public protocol NationalTransferInputRepresentable {
    var beneficiary: String { get }
    var isSpanishResident: Bool { get }
    var saveAsUsual: Bool { get }
    var saveAsUsualAlias: String? { get }
    var beneficiaryMail: String? { get }
    var concept: String? { get }
}
