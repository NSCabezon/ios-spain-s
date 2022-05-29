//
//  AccountFutureBillListRepresentable.swift
//  CoreDomain
//
//  Created by David Gálvez Alonso on 7/12/21.
//

import Foundation

public protocol AccountFutureBillListRepresentable {
    var billListRepresentable: [AccountFutureBillRepresentable] { get }
    var additionalInfoRepresentable: AditionalInfoRepresentable? { get }
}
