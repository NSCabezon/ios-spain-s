//
//  PublicFilesEnvironmentEntity.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/26/20.
//

import Foundation

public struct PublicFilesEnvironmentEntity: CustomStringConvertible, Codable, DTOInstantiable {
    public let dto: PublicFilesEnvironmentDTO
    
    public init(_ dto: PublicFilesEnvironmentDTO) {
        self.dto = dto
    }

    public func getPublicFilesEnvironment() -> PublicFilesEnvironmentDTO {
        return dto
    }

    public var name: String {
        return dto.name!
    }

    public var urlBase: String {
        return dto.urlBase!
    }

    public var description: String {
        return "\(name): \(urlBase)"
    }
}
