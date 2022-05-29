//
//  FailableDecodable.swift
//  CiberCodeTest
//
//  Created by José Estela on 25/9/18.
//  Copyright © 2018 Jose Carlos Estela. All rights reserved.
//

import Foundation

struct FailableDecodable<Base: Decodable>: Decodable {
    
    let base: Base?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self.base = try container.decode(Base.self)
        } catch {
            self.base = nil
            print(error)
        }
    }
}

struct FailableCodableArray<Element: Codable>: Codable {
    
    var elements: [Element]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements = [Element]()
        if let count = container.count {
            elements.reserveCapacity(count)
        }
        while !container.isAtEnd {
            if let element = try container.decode(FailableDecodable<Element>.self).base {
                elements.append(element)
            }
        }
        self.elements = elements
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(elements)
    }
    
    init(elements: [Element]) {
        self.elements = elements
    }
}
