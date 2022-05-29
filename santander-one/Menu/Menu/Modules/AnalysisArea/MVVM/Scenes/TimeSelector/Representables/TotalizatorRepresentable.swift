//
//  TotalizatorRepresentable.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 24/2/22.
//

import Foundation

public protocol TotalizatorRepresentable {
    var productsInfo: (Int, Int) { get }
    var banksImages: [BankImageRepresentable] { get }
}

public protocol BankImageRepresentable {
    var urlImage: String { get }
    var accessibilityLabelKey: String { get }
}
