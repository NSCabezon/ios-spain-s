//
//  DigitalProfilePercentageRepresentable.swift
//  CoreDomain
//
//  Created by Daniel Gómez Barroso on 23/12/21.
//

public protocol DigitalProfilePercentageRepresentable {
    var percentage: Double { get }
    var notConfiguredItems: [DigitalProfileElemProtocol] { get }
}
