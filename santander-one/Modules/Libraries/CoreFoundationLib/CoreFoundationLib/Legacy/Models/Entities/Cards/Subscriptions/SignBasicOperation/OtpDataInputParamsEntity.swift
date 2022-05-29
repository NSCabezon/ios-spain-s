//
//  OtpDataInputParamsEntity.swift
//  Cards
//
//  Created by Rubén Márquez Fernández on 10/5/21.
//

import Foundation
import SANLegacyLibrary

public protocol OtpDataInputParamsEntityRepresentable {
    var xmlOperative: String { get }
    var codeOTP: String { get }
    var ticketOTP: String { get }
    var company: String { get }
    var language: String { get }
    var channel: String { get }
}

public struct OtpDataInputParamsEntity: OtpDataInputParamsEntityRepresentable {
    private let dto: OtpDataInputParams
    public init(dto: OtpDataInputParams) {
        self.dto = dto
    }
    
    public var xmlOperative: String {
        return dto.xmlOperative
    }
    
    public var codeOTP: String {
        return dto.codeOTP
    }
    
    public var ticketOTP: String {
        return dto.ticketOTP
    }
    
    public var company: String {
        return dto.company
    }
    
    public var language: String {
        return dto.language
    }
    
    public var channel: String {
        return dto.channel
    }
    
}
