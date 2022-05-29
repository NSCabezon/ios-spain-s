//
//  Cancelable.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/16/20.
//

import Foundation

public protocol Cancelable: AnyObject {
    func cancel()
}
