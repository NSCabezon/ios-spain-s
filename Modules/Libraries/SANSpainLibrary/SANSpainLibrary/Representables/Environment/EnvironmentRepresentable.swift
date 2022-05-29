//
//  EnvironmentRepresentable.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 12/5/21.
//

import Foundation

public protocol EnvironmentRepresentable {
    var soapBaseUrl: String { get }
    var restBaseUrl: String { get }
    var santanderKeyUrl: String { get }
}
