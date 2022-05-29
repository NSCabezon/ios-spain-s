//
//  OptDataEntity.swift
//  Cards
//
//  Created by Rubén Márquez Fernández on 6/5/21.
//

import SANLegacyLibrary

public protocol OtpDataEntityRepresentable {
    var xmlOperative: String { get }
    var codeOTP: String? { get }
    var ticketOTP: String { get }
    var company: String { get }
    var language: String { get }
    var channel: String { get }
    var contract: String { get }
}

public struct OtpDataEntity: OtpDataEntityRepresentable {
    private let dto: OtpData
    public init(dto: OtpData) {
        self.dto = dto
    }
    
    public var xmlOperative: String {
        return dto.xmlOperative
    }
    
    public var codeOTP: String? {
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
    
    public var contract: String {
        return dto.contract
    }
}
