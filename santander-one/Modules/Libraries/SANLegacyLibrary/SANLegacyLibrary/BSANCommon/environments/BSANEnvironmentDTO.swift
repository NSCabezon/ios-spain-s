import Foundation
import CoreDomain

public class BSANEnvironmentDTO: Hashable, CustomStringConvertible, Codable {
    public let isHttps: Bool
    public let name: String
    public let urlBase: String
    public let urlNetInsight: String
    public let urlSocius: String
    public let urlBizumEnrollment: String
    public let urlBizumWeb: String?
    public let urlGetCMC: String?
    public let urlGetNewMagic: String?
    public let urlForgotMagic: String?
    public let urlRestBase: String?
    public let oauthClientId: String
    public let oauthClientSecret: String
    public let microURL: String?
    public let click2CallURL: String?
    public let branchLocatorGlobile: String?
    public let insurancesPass2Url: String?
    public let pass2oauthClientId: String
    public let pass2oauthClientSecret: String
    public let ecommerceUrl: String?
    public let fintechUrl: String?
    public let santanderKeyUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case isHttps
        case name
        case urlBase
        case urlNetInsight
        case urlSocius
        case urlBizumEnrollment
        case urlBizumWeb
        case urlGetCMC
        case urlGetNewMagic = "urlGetNewPassword"
        case urlForgotMagic = "urlForgotPassword"
        case urlRestBase
        case oauthClientId
        case oauthClientSecret
        case microURL
        case click2CallURL
        case branchLocatorGlobile
        case insurancesPass2Url
        case pass2oauthClientId
        case pass2oauthClientSecret
        case ecommerceUrl
        case fintechUrl
        case santanderKeyUrl
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
        santanderKeyUrl: String? = nil) {
        self.urlBase = urlBase
        self.isHttps = isHttps
        self.name = name
        self.urlNetInsight = urlNetInsight
        self.urlSocius = urlSocius
        self.urlBizumEnrollment = urlBizumEnrollment
        self.urlBizumWeb = urlBizumWeb
        self.urlGetCMC = urlGetCMC
        self.urlGetNewMagic = urlGetNewMagic
        self.urlForgotMagic = urlForgotMagic
        self.urlRestBase = urlRestBase
        self.oauthClientId = oauthClientId
        self.oauthClientSecret = oauthClientSecret
        self.microURL = microURL
        self.click2CallURL = click2CallURL
        self.branchLocatorGlobile = branchLocatorGlobile
        self.insurancesPass2Url = insurancesPass2Url
        self.pass2oauthClientId = pass2oauthClientId
        self.pass2oauthClientSecret = pass2oauthClientSecret
        self.ecommerceUrl = ecommerceUrl
        self.fintechUrl = fintechUrl
        self.santanderKeyUrl = santanderKeyUrl
    }
    
    public var description: String {
        return "\(name) : \(urlBase)"
    }
    
    public func hash(into hasher: inout Hasher) {
        guard let hash = Int(name) else { return hasher.combine(0) }
        return hasher.combine(hash)
    }
    
    public static func ==(lhs: BSANEnvironmentDTO, rhs: BSANEnvironmentDTO) -> Bool {
        return lhs.name == rhs.name
    }
}

extension BSANEnvironmentDTO: EnvironmentsRepresentable { }
