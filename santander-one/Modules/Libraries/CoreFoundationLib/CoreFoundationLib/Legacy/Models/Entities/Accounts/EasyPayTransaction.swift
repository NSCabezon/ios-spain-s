//
//  EasyPayTransaction.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 01/09/2020.
//

import Foundation

public protocol EasyPayTransaction {
    var description: String? { get }
    var operationDate: Date? { get }
}
