//
//  PGBoxDTO.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 14/12/21.
//

import Foundation

public struct PGBoxDTO: Codable {
    public var isOpen: Bool    
    public var _products: [String: PGBoxItemDTO]
    
    public init(isOpen: Bool, _products: [String: PGBoxItemDTO]) {
        self.isOpen = isOpen
        self._products = _products
    }
}

extension PGBoxDTO {
    var count: Int {
        return _products.count
    }
    var sortedProducts: [PGBoxItemDTO] {
        return _products.values.sorted { $0.order < $1.order }
    }
    
    init() {
        isOpen = true
        _products = [:]
    }
}

public extension PGBoxDTO {
    mutating func set(item: PGBoxItemDTO, withIdentifier identifier: String) {
        _products[identifier] = item
    }
    
    func getItem(withIdentifier identifier: String) -> PGBoxItemDTO? {
        return _products[identifier]
    }
    
    mutating func removeAllItems() {
        _products = [:]
    }
}
