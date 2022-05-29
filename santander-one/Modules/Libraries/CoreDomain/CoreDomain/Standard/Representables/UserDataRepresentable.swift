//
//  UserDataRepresentable.swift
//  CoreFoundationLib
//
//  Created by José María Jiménez Pérez on 28/7/21.
//

public protocol UserDataRepresentable {
    var clientPersonType: String? { get }
    var clientPersonCode: String? { get }
    var channelFrame: String? { get }
    var company: String? { get }
    var contractRepresentable: ContractRepresentable? { get }
}
