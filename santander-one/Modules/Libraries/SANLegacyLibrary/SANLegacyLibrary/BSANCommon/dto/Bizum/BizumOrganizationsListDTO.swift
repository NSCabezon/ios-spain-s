//
//  BizumOrganizationsListDTO.swift
//  SANLegacyLibrary
//
//  Created by Carlos Monfort Gómez on 02/02/2021.
//

import Foundation

public struct BizumOrganizationsListDTO: Codable {
    public let info: BizumOrganizationsListInfoDTO
    public let elementsTotal: Int?
    public let pagesTotal: Int?
    public let moreData: Int
    public var organizations: [BizumOrganizationDTO] {
        return organizationsList.organizations
    }
    private let organizationsList: BizumOrganizationListOrganizationsDTO

    private enum CodingKeys: String, CodingKey {
        case info
        case elementsTotal = "numeroTotalElementos"
        case pagesTotal = "numeroTotalpaginas"
        case moreData = "masDatos"
        case organizationsList = "consultaOrganizaciones"
    }
}

public struct BizumOrganizationsListInfoDTO: Codable {
    public let errorCode: String
    public let errorDesc: String?
}

struct BizumOrganizationListOrganizationsDTO: Codable {
    let organizations: [BizumOrganizationDTO]
    
    private enum CodingKeys: String, CodingKey {
        case organizations = "consultaOrganizaciones"
    }
}

extension BizumOrganizationsListDTO: DateParseable {
    public static var formats: [String: String] {
        return [
            "consultaOrganizaciones.consultaOrganizaciones.fechaInicio": "yyyy-MM-dd HH:mm:ss:S",
            "consultaOrganizaciones.consultaOrganizaciones.fechaFin": "yyyy-MM-dd HH:mm:ss:S",
        ]
    }
}

