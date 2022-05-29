//
//  AccountEasyPayRepresentable.swift
//  CoreDomain
//
//  Created by David Gálvez Alonso on 21/1/22.
//

public protocol AccountEasyPayRepresentable {
    var campaignCode: String { get }
    var grantedAmountRepresentable: AmountRepresentable { get }
}
