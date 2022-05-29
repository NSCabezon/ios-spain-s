//
//  OTPValidationRepresentable.swift
//  CoreFoundationLib
//
//  Created by José María Jiménez Pérez on 27/7/21.
//

import Foundation

public protocol OTPValidationRepresentable: Codable {
    var magicPhrase: String? { get set }
    var ticket: String? { get }
    var otpExcepted: Bool { get }
}
