//
//  BSANEnvironmentEntity.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/26/20.
//

import Foundation
import SANLegacyLibrary

public struct EnvironmentEntity: CustomStringConvertible, Codable, DTOInstantiable {
    public var dto: BSANEnvironmentDTO
    
    public init(_ dto: BSANEnvironmentDTO) {
        self.dto = dto
    }
    
    public init(
        urlBase: String,
        isHttps: Bool,
        name: String,
        urlNetInsight: String,
        urlSocius: String,
        urlBizumEnrollment: String,
        urlBizumWeb: String?,
        urlGetCMC: String?,
        urlGetNewMagic: String?,
        urlForgotMagic: String?,
        urlRestBase: String?,
        oauthClientId: String,
        oauthClientSecret: String,
        microURL: String?,
        click2CallURL: String?,
        branchLocatorGlobile: String?,
        insurancesPass2Url: String?,
        pass2oauthClientId: String,
        pass2oauthClientSecret: String,
        ecommerceUrl: String,
        fintechUrl: String,
        santanderKeyUrl: String
    ) {
        self.dto = BSANEnvironmentDTO(
            urlBase: urlBase,
            isHttps: isHttps,
            name: name,
            urlNetInsight: urlNetInsight,
            urlSocius: urlSocius,
            urlBizumEnrollment: urlBizumEnrollment,
            urlBizumWeb: urlBizumWeb,
            urlGetCMC: urlGetCMC,
            urlGetNewMagic: urlGetNewMagic,
            urlForgotMagic: urlForgotMagic,
            urlRestBase: urlRestBase,
            oauthClientId: oauthClientId,
            oauthClientSecret: oauthClientSecret,
            microURL: microURL,
            click2CallURL: click2CallURL,
            branchLocatorGlobile: branchLocatorGlobile,
            insurancesPass2Url: insurancesPass2Url,
            pass2oauthClientId: pass2oauthClientId,
            pass2oauthClientSecret: pass2oauthClientSecret,
            ecommerceUrl: ecommerceUrl,
            fintechUrl: fintechUrl,
            santanderKeyUrl: santanderKeyUrl
        )
    }

    public func getBSANEnvironmentDTO() -> BSANEnvironmentDTO {
        return self.dto
    }
    
    public var name: String {
        return self.dto.name
    }
    
    public var urlGetNewPassword: String? {
        return self.dto.urlGetNewMagic
    }
    
    public var urlForgotPassword: String? {
        return self.dto.urlForgotMagic
    }
    
    public var urlBase: String {
        return self.dto.urlBase
    }
    
    public var urlGetCMC: String? {
        return self.dto.urlGetCMC
    }
    
    public var description: String {
        return "\(name): \(urlBase)"
    }
}
