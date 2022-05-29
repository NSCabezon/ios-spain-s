import SANLibraryV3

struct GeneralEndpoints {
    static let endpointPro = "https://www.bsan.mobi"
    static let niEndpointPro = "https://www.bsan.mobi/Estatico/ntpagetag.gif"
}

struct SociusEndpoints {
    static let sociusEndpointUrlPro = "https://adn.bsan.mobi"
}

struct BizumEndpoints {
    static let bizumEnrollmentEndpointUrlPro = "https://pagosinmediatos.santander.pre.corp"
    static let bizumWebviewUrlPro = "https://pagosinmediatos.bancosantander.es/PAINOP_BIZUMWEB/index.jsp"
    static let bizumWebViewUrl = "https://pagosinmediatos.bancosantander.es/PAINOP_BIZUMWEB/index.jsp"
}

struct CMCEndpoints {
    static let getCmcUrlPro = "https://cmc.bancosantander.es/ALTCMC_PHOENIX"
}

struct MagicEndpoints {
    // Recover magic -> Lateral drawer
    static let getNewMagicUrlPro = "https://cmc.bancosantander.es/REGCLA_PHOENIX/static/index.html?sty=APP"
    // Recover magic -> Principal screen
    static let forgetMagicUrlPro = "https://cmc.bancosantander.es/REGCLA_PHOENIX/static/index.html?sty=APP"
}

struct InsuranceEndpoints {
    static let insurancesEndpointUrlPro = "https://api.bancosantander.es/canales-digitales/internet-pro/"
    static let insurancesPaas2EndpointUrlPro = "https://apis.bancosantander.es/canales-digitales/internet/"
}

struct RestEndpoints {
    static let restOauthClientIdPro = "977875fa-a091-499c-8bad-c7cb3b075df5"
    static let restOauthClientSecretPro = "A1bF8vK0mI2oV6lE7eH4pY7vH4kI7mC5uN2fW7vW4dO6pE7uE6"
    static let pass2RestOauthClientIdPro = "634bba61-055a-4298-8b0d-dead446a358a"
    static let pass2RestOauthClientSecretPro = "kW2gB3fS8oH4iF7iM6yI8aJ1rH4lE7nD3xJ5jH8oC2wG5vR8fB"
}

struct EcommerceEndpoints {
    static let ecommerceMicroUrlPro = "https://scaweb.bsan.mobi"
}

struct FintechEndpoints {
    static let fintechUrlPro = "https://apis.bancosantander.es"
}

struct MicroEndpoints {
    static let microUrlPro = "https://sanesp.mobi"
}

struct SantanderKeyEndpoints {
    static let santanderKeyPro = "https://sankey.mobi"
}

struct Click2CallEndpoints {
    static let click2CallUrlPRO = "https://click2call.gruposantander.es/c2c/api/app/"
}

struct BranchLocatorEndpoints {
    static let branchLocatorGlobile = "https://back-weu.azurewebsites.net"
}

public struct BSANEnvironments {
    static let environmentPro = BSANEnvironmentDTO(
        urlBase: GeneralEndpoints.endpointPro,
        isHttps: false,
        name: "PRO",
        urlNetInsight: GeneralEndpoints.niEndpointPro,
        urlSocius: SociusEndpoints.sociusEndpointUrlPro,
        urlBizumEnrollment: BizumEndpoints.bizumEnrollmentEndpointUrlPro,
        urlBizumWeb: BizumEndpoints.bizumWebviewUrlPro,
        urlGetCMC: CMCEndpoints.getCmcUrlPro,
        urlGetNewMagic: MagicEndpoints.getNewMagicUrlPro,
        urlForgotMagic: MagicEndpoints.forgetMagicUrlPro,
        urlRestBase: InsuranceEndpoints.insurancesEndpointUrlPro,
        oauthClientId: RestEndpoints.restOauthClientIdPro,
        oauthClientSecret: RestEndpoints.restOauthClientSecretPro,
        microURL: MicroEndpoints.microUrlPro,
        click2CallURL: Click2CallEndpoints.click2CallUrlPRO,
        branchLocatorGlobile: BranchLocatorEndpoints.branchLocatorGlobile,
        insurancesPass2Url: InsuranceEndpoints.insurancesPaas2EndpointUrlPro,
        pass2oauthClientId: RestEndpoints.pass2RestOauthClientIdPro,
        pass2oauthClientSecret: RestEndpoints.pass2RestOauthClientSecretPro,
        ecommerceUrl: EcommerceEndpoints.ecommerceMicroUrlPro,
        fintechUrl: FintechEndpoints.fintechUrlPro,
        santanderKeyUrl: SantanderKeyEndpoints.santanderKeyPro
    )
}
