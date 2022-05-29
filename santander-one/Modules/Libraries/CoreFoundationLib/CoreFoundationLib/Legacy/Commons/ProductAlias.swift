//
//  ProductAlias.swift
//  Commons
//
//  Created by Alvaro Royo on 7/1/22.
//

import Foundation
import CoreDomain

public protocol ProductAliasManagerProtocol {
    func getProductAlias(for aliasType: ProductTypeEntity) -> ProductAlias?
}

public class ProductAlias {
    public let charSet: CharacterSet
    public let maxChars: Int

    public init(charSet: CharacterSet, maxChars: Int) {
        self.charSet = charSet
        self.maxChars = maxChars
    }
}
