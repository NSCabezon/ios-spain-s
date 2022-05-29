//
//  BizumNGO.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 15/02/2021.
//

import Foundation

let organizationCodePrefix = "+999999999"
let organizationCodeLength = 5

protocol BizumNGOProtocol {
    var name: String { get }
    var alias: String { get }
    var identifier: String { get }
}

struct BizumNGO: BizumNGOProtocol {
    var name: String
    var alias: String
    var identifier: String
}
