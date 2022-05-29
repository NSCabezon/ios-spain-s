//
//  BizumOrganizationDTO.swift
//  SANLegacyLibrary
//
//  Created by Carlos Monfort Gómez on 02/02/2021.
//

import Foundation

public struct BizumOrganizationDTO: Codable {
    public let identifier: String
    public let userType: String
    public let name: String
    public let alias: String
    public let documentId: String
    public let documentIdType: String
    public let mail: String
    public let startDate: Date?
    public let endDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "identificador"
        case userType = "tipoUsuario"
        case name = "nombreOrganizacion"
        case alias = "aliasOrganizacion"
        case documentId = "documentoIdentificacion"
        case documentIdType = "tipoDocumentoIdentificacion"
        case mail = "email"
        case startDate = "fechaInicio"
        case endDate = "fechaFin"
    }
}

