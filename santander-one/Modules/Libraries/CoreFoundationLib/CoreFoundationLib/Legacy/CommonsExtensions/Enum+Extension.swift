//
//  Enum+Extension.swift
//  CoreFoundationLib
//
//  Created by Jose Javier Montes Romero on 8/2/22.
//

import Foundation

public extension CaseIterable where Self: Equatable {
    public func elementIndex() -> Self.AllCases.Index {
        return Self.allCases.firstIndex(of: self)!
    }
}
