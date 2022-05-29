//
//  PendingSolicitudeEntity.swift
//  Models
//
//  Created by Juan Carlos López Robles on 1/16/20.
//

import Foundation
import SANLegacyLibrary

public final class PendingSolicitudeListEntity: DTOInstantiable {
    public let dto: PendingSolicitudeListDTO
    
    public init(_ dto: PendingSolicitudeListDTO) {
        self.dto = dto
    }
    
    public var pendingSolicitudes: [PendingSolicitudeEntity] {
        return dto.solicitudesDTOs?.map {PendingSolicitudeEntity($0)} ?? []
    }
}

public final class PendingSolicitudeEntity: DTOInstantiable {
    public let dto: PendingSolicitudeDTO
    
    public init(_ dto: PendingSolicitudeDTO) {
        self.dto = dto
    }
    
    public var identifier: String? {
        return dto.identifier
    }
    
    public var name: String? {
        return dto.name
    }
    
    public var startDate: Date? {
        return dto.startDate
    }
    
    public var expirationDate: Date? {
        return dto.expirationDate
    }
    
    public var businessCode: String? {
        return dto.businessCode
    }
    
    public var solicitudeState: String? {
        return dto.solicitudeState
    }
    
    public var solicitudeType: String? {
        return dto.solicitudeType
    }
    
    public var chanel: String? {
        return dto.chanel
    }
    
    public var chanelDescription: String? {
        return dto.chanelDescription
    }
    
    public var rightWithdrawal: String? {
        return dto.rightWithdrawal
    }
    
    public var sign: String? {
        return dto.sign
    }
}

extension PendingSolicitudeEntity: Hashable {
    public static func == (lhs: PendingSolicitudeEntity, rhs: PendingSolicitudeEntity) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(startDate)
        hasher.combine(expirationDate)
        hasher.combine(businessCode)
        hasher.combine(solicitudeState)
        hasher.combine(solicitudeType)
        hasher.combine(chanel)
        hasher.combine(chanelDescription)
        hasher.combine(rightWithdrawal)
        hasher.combine(sign)
        hasher.combine(identifier)
    }
}
