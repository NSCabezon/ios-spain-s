//
//  CountryDTO.swift
//  Models
//
//  Created by alvola on 19/03/2020.
//

public struct CountryDTO: Codable {
    public let code: String
    public let currency: String
    public let name: String
    public let dataEmbassy: EmbassyDTO
    public init(code: String,
                currency: String,
                name: String,
                dataEmbassy: EmbassyDTO) {
        self.code = code
        self.currency = currency
        self.name = name
        self.dataEmbassy = dataEmbassy
    }
}

public struct EmbassyDTO: Codable {
    public let titleEmbassy: String
    public let addressEmbassy: String
    public let titleTelephoneEmbassy: String
    public let telephoneEmbassy: String
    public let titleConsularEmergency: String
    public let telephoneConsularEmergency: String
    
    public init(titleEmbassy: String,
                addressEmbassy: String,
                titleTelephoneEmbassy: String,
                telephoneEmbassy: String,
                titleConsularEmergency: String,
                telephoneConsularEmergency: String) {
        self.titleEmbassy = titleEmbassy
        self.addressEmbassy = addressEmbassy
        self.titleTelephoneEmbassy = titleTelephoneEmbassy
        self.telephoneEmbassy = telephoneEmbassy
        self.titleConsularEmergency = titleConsularEmergency
        self.telephoneConsularEmergency = telephoneConsularEmergency
    }
}
