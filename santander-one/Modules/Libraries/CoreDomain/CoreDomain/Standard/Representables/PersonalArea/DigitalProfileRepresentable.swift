//
//  DigitalProfileRepresentable.swift
//  CoreDomain
//
//  Created by alvola on 18/4/22.
//

import Foundation

public protocol DigitalProfileRepresentable {
    var percentage: Double { get }
    var category: DigitalProfileEnum { get }
    var configuredItems: [DigitalProfileElemProtocol] { get }
    var notConfiguredItems: [DigitalProfileElemProtocol] { get }
    var username: String { get }
    var userLastname: String { get }
    var userImage: Data? { get }
}
