//
//  CountryEntity.swift
//  Models
//
//  Created by alvola on 19/03/2020.
//

import CoreDomain

public final class CountryEntity: Codable, DTOInstantiable {
    public var dto: CountryDTO
    
    public init(_ dto: CountryDTO) {
        self.dto = dto
    }
    
    public init(code: String,
                currency: String,
                name: String,
                embassyTitle: String,
                embassyAddress: String,
                embassyTitleTelephone: String,
                embassyTelephone: String,
                embassyTitleConsular: String,
                embassyTelephoneConsularEmergency: String) {
        let embassy = EmbassyDTO(titleEmbassy: embassyTitle,
                                 addressEmbassy: embassyAddress,
                                 titleTelephoneEmbassy: embassyTitleTelephone,
                                 telephoneEmbassy: embassyTelephone,
                                 titleConsularEmergency: embassyTitleConsular,
                                 telephoneConsularEmergency: embassyTelephoneConsularEmergency)
        self.dto = CountryDTO(code: code, currency: currency, name: name, dataEmbassy: embassy)
    }
    
    public var code: String {
        dto.code
    }
    public var currency: String {
        dto.currency
    }
    public var name: String {
        dto.name
    }
    public var embassyTitle: String {
        dto.dataEmbassy.titleEmbassy
    }
    public var embassyAddress: String {
        dto.dataEmbassy.addressEmbassy
    }
    public var embassyTitleTelephone: String {
        dto.dataEmbassy.titleTelephoneEmbassy
    }
    public var embassyTelephone: String {
        dto.dataEmbassy.telephoneEmbassy
    }
    public var embassyTitleConsular: String {
        dto.dataEmbassy.titleConsularEmergency
    }
    public var embassyTelephoneConsularEmergency: String {
        dto.dataEmbassy.telephoneConsularEmergency
    }
}

extension CountryEntity: Equatable {
    public static func == (lhs: CountryEntity, rhs: CountryEntity) -> Bool {
        return  lhs.code == rhs.code &&
                lhs.currency == rhs.currency &&
                lhs.name == rhs.name &&
                lhs.embassyTitle == rhs.embassyTitle &&
                lhs.embassyAddress == rhs.embassyAddress &&
                lhs.embassyTitleTelephone == rhs.embassyTitleTelephone &&
                lhs.embassyTitleConsular == rhs.embassyTitleConsular &&
                lhs.embassyTelephoneConsularEmergency == rhs.embassyTelephoneConsularEmergency
    }
}

extension CountryEntity: CountryRepresentable {}
