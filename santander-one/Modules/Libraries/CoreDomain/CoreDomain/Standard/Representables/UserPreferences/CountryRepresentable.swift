//
//  Country.swift
//  CoreDomain
//
//  Created by Jose Ignacio de Juan Díaz on 27/12/21.
//

import Foundation

public protocol CountryRepresentable {
    var code: String { get }
    var currency: String { get }
    var name: String { get }
    var embassyTitle: String { get }
    var embassyAddress: String { get }
    var embassyTitleTelephone: String { get }
    var embassyTelephone: String { get }
    var embassyTitleConsular: String { get }
    var embassyTelephoneConsularEmergency: String { get }
}
