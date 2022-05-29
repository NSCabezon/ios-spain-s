//
//  SignatureRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 19/08/2021.
//

import Foundation

public protocol SignatureRepresentable {
    var length: Int? { get }
    var positions: [Int]? { get }
    var values: [String]? { get set }
}
