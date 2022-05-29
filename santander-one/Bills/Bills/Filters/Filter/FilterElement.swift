//
//  FilterElement.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/20/20.
//

import Foundation

struct FilterElement<V, I> {
    let name: String
    let value: V
    let selection: I
}
