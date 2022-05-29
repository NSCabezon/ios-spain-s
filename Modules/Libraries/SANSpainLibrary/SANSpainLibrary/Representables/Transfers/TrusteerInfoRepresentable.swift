//
//  TrusteerInfoRepresentable.swift
//  SANSpainLibrary
//
//  Created by José María Jiménez Pérez on 27/7/21.
//

import Foundation

public protocol TrusteerInfoRepresentable {
    var userAgent: String { get }
    var customerSessionId: String { get }
    var disabledServicesIP: [String] { get }
    var remoteAddr: String { get }
}
