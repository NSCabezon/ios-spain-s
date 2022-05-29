import SANLibraryV3

struct GeneralEndpoints {
    static let endpointPro = "https://www.bsan.mobi"
    static let endpointOcu = "https://wwwocu.bsan.mobi"
    static let endpointPre = "https://movilidad.santander.pre.corp"
    static let endpointDev = "https://desextranet.isban.dev.corp"
    static let endpointCiber = "http://10.6.0.34:8080/ciber/pre/tunel"
    static let endPointPreWas9 = "https://movretail.santander.pre.corp"
    static let niEndpointPro = "https://www.bsan.mobi/Estatico/ntpagetag.gif"
    static let niEndpointOcu = "https://wwwocu.bsan.mobi/Estatico/ntpagetag.gif"
    static let niEndpointPre = "https://movilidad.santander.pre.corp/Estatico/ntpagetag.gif"
    static let niEndpointDev = "https://wwwocu.bsan.mobi/Estatico/ntpagetag.gif"
    static let niEndpointCiber = "" // NetInsight doesn't work via tunnel
}

struct SociusEndpoints {
    static let sociusEndpointUrlPro = "https://adn.bsan.mobi"
    static let sociusEndpointUrlOcu = "https://adn.bsan.mobi"
    static let sociusEndpointUrlPre = "http://nuevoportalcliente.pru.bsch/adn-ws-socius-s/ADNCalSOCPortS"
    static let sociusEndpointUrlDev = "http://nuevoportalcliente.pru.bsch/adn-ws-socius-s/ADNCalSOCPortS"
    static let sociusEndpointUrlCiber = "http://10.6.0.34:8080/ciber/pre/sociustunel"
}

struct BizumEndpoints {
    static let bizumEnrollmentEndpointUrlPro = "https://pagosinmediatos.santander.pre.corp"
    static let bizumEnrollmentEndpointUrlOcu = "https://pagosinmediatos.santander.pre.corp"
    static let bizumEnrollmentEndpointUrlPre = "https://pagosinmediatos.santander.pre.corp"
    static let bizumEnrollmentEndpointUrlDev = "https://pagosinmediatos.santander.pre.corp"
    static let bizumEnrollmentEndpointUrlCiber = "http://10.6.0.34:8080/ciber/pre/altatunel"
    static let bizumWebviewUrlCiber = "http://10.6.0.34:8080/ciber/pre/altatunel/PAINOP_BIZUMWEB/index.jsp"
    static let bizumWebviewUrlPre = "https://pagosinmediatos.santander.pre.corp/PAINOP_BIZUMWEB/index.jsp"
    static let bizumWebviewUrlPro = "https://pagosinmediatos.bancosantander.es/PAINOP_BIZUMWEB/index.jsp"
    static let bizumWebviewUrlDev: String? = nil
    static let bizumWebviewUrlOcu = "https://pagosinmediatosocu.bancosantander.es/PAINOP_BIZUMWEB/index.jsp"
}

struct CMCEndpoints {
    static let getCmcUrlCiber: String? = nil
    static let getCmcUrlPre: String? = nil
    static let getCmcUrlPro = "https://cmc.bancosantander.es/ALTCMC_PHOENIX"
    static let getCmcUrlDev: String? = nil
    static let getCmcUrlOcu: String? = nil
}

struct MagicEndpoints {
    // Recover magic -> Principal screen
    static let forgetMagicUrlCiber: String? = nil
    static let forgetMagicUrlPre = "https://cmc.santander.pre.corp/REGCLA_PHOENIX/static/index.html?sty=APP"
    static let forgetMagicUrlPro = "https://cmc.bancosantander.es/REGCLA_PHOENIX/static/index.html?sty=APP"
    static let forgetMagicUrlDev: String? = nil
    static let forgetMagicUrlOcu = "https://cmcocu.bancosantander.es/REGCLA_PHOENIX/static/index.html?sty=APP"
    // Recover magic -> Lateral drawer
    static let getNewMagicUrlCiber: String? = nil
    static let getNewMagicUrlPre = "https://cmc.santander.pre.corp/REGCLA_PHOENIX/static/index.html?sty=APP"
    static let getNewMagicUrlPro = "https://cmc.bancosantander.es/REGCLA_PHOENIX/static/index.html?sty=APP"
    static let getNewMagicUrlDev: String? = nil
    static let getNewMagicUrlOcu = "https://cmcocu.bancosantander.es/REGCLA_PHOENIX/static/index.html?sty=APP"
}

struct InsuranceEndpoints {
    static let insurancesEndpointUrlPro = "https://api.bancosantander.es/canales-digitales/internet-pro/"
    static let insurancesEndpointUrlOcu = "https://api.bancosantander.es/canales-digitales/internet-pro/"
    static let insurancesEndpointUrlPre = "https://apigateway-internet.santander.pre.corp/canales-digitales/internet/"
    static let insurancesEndpointUrlDev: String? = nil
    static let insurancesEndpointUrlCiber = "http://10.6.0.34:8080/ciber/pre/apirest/"
    static let insurancesPaas2EndpointUrlPro = "https://apis.bancosantander.es/canales-digitales/internet/"
    static let insurancesPass2EndpointUrlOcu = "https://apis.bancosantander.es/canales-digitales/internet/"
    static let insurancesPass2EndpointUrlPre = "https://apigtw-sanes-internet.santander.pre.corp/canales-digitales/internet/"
    static let insurancesPass2EndpointUrlDev = "https://apigtw-sanes-internet.santander.pre.corp/canales-digitales/internet/"
    static let insurancesPass2EndpointUrlCiber = "http://10.6.0.34:8080/ciber/pre/newapirest/"
}

struct RestEndpoints {
    static let restOauthClientIdPre = "119285e3-841c-4d2c-b831-19911bf91343"
    static let restOauthClientSecretPre = "dU6rX8iX7yQ3xB7gI7pN7dI6oW0tM0tD2wX4jU7eP4uI3mP0eF"
    static let restOauthClientIdPro = "977875fa-a091-499c-8bad-c7cb3b075df5"
    static let restOauthClientSecretPro = "A1bF8vK0mI2oV6lE7eH4pY7vH4kI7mC5uN2fW7vW4dO6pE7uE6"
    static let pass2RestOauthClientIdPre = "4a4fa5a5-2a08-4bb3-9fd3-ebbe79c4567a"
    static let pass2RestOauthClientSecretPre = "H3hJ6yA3yB0mK7wG8dH7lQ0iT8bA6tQ1fH5uT7uP4tR7dV2xV5"
    static let pass2RestOauthClientIdPro = "634bba61-055a-4298-8b0d-dead446a358a"
    static let pass2RestOauthClientSecretPro = "kW2gB3fS8oH4iF7iM6yI8aJ1rH4lE7nD3xJ5jH8oC2wG5vR8fB"
}

struct EcommerceEndpoints {
    static let ecommerceMicroUrlPre = "https://scammppweb.pru.bsch"
    static let ecommerceMicroUrlPro = "https://scaweb.bsan.mobi"
    static let ecommerceMicroUrlCiber = ""
}

struct FintechEndpoints {
    static let fintechUrlPre = "https://apigtw-sanes-internet.santander.pre.corp"
    static let fintechUrlPro = "https://apis.bancosantander.es"
    static let fintechUrlCiber = ""
}

struct MicroEndpoints {
    static let microUrlPre = "https://sanesp-pre.pru.bsch"
    static let microUrlOcu = "https://sanespmobi-ocu.corp.bsch"
    static let microUrlPro = "https://sanesp.mobi"
    static let microUrlCiber = "http://10.6.0.34:8080/ciber/pre/apirestsaas/"
}

struct SantanderKeyEndpoints {
    static let santanderKeyPre = "https://sankey.pru.bsch"
    static let santanderKeyOcu = "https://sankey.ocu.bsch"
    static let santanderKeyPro = "https://sankey.mobi"
}

struct Click2CallEndpoints {
    static let click2CallUrlPRE = "https://click2callapp.pru.bsch/c2c/api/app/"
    static let click2CallUrlPRO = "https://click2call.gruposantander.es/c2c/api/app/"
    static let click2CallUrlCiber = "http://10.6.0.34:8080/ciber/pre/click2callapp/"
}

struct BranchLocatorEndpoints {
    static let branchLocatorGlobile = "https://back-weu.azurewebsites.net"
}

public struct BSANEnvironments {
    static let branchLocatorGlobile = "https://back-weu.azurewebsites.net"

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
    static let environmentOcu = BSANEnvironmentDTO(
        urlBase: GeneralEndpoints.endpointOcu,
        isHttps: false,
        name: "OCU",
        urlNetInsight: GeneralEndpoints.niEndpointOcu,
        urlSocius: SociusEndpoints.sociusEndpointUrlOcu,
        urlBizumEnrollment: BizumEndpoints.bizumEnrollmentEndpointUrlOcu,
        urlBizumWeb: BizumEndpoints.bizumWebviewUrlOcu,
        urlGetCMC: CMCEndpoints.getCmcUrlOcu,
        urlGetNewMagic: MagicEndpoints.getNewMagicUrlOcu,
        urlForgotMagic: MagicEndpoints.forgetMagicUrlOcu,
        urlRestBase: InsuranceEndpoints.insurancesEndpointUrlOcu,
        oauthClientId: RestEndpoints.restOauthClientIdPro,
        oauthClientSecret: RestEndpoints.restOauthClientSecretPro,
        microURL: MicroEndpoints.microUrlOcu,
        click2CallURL: Click2CallEndpoints.click2CallUrlPRO,
        branchLocatorGlobile: BranchLocatorEndpoints.branchLocatorGlobile,
        insurancesPass2Url: InsuranceEndpoints.insurancesPass2EndpointUrlOcu,
        pass2oauthClientId: RestEndpoints.pass2RestOauthClientIdPro,
        pass2oauthClientSecret: RestEndpoints.pass2RestOauthClientSecretPro,
        ecommerceUrl: EcommerceEndpoints.ecommerceMicroUrlPro,
        fintechUrl: FintechEndpoints.fintechUrlPro,
        santanderKeyUrl: SantanderKeyEndpoints.santanderKeyOcu
    )
    static let environmentPre = BSANEnvironmentDTO(
        urlBase: GeneralEndpoints.endpointPre,
        isHttps: false,
        name: "PRE",
        urlNetInsight: GeneralEndpoints.niEndpointPre,
        urlSocius: SociusEndpoints.sociusEndpointUrlPre,
        urlBizumEnrollment: BizumEndpoints.bizumEnrollmentEndpointUrlPre,
        urlBizumWeb: BizumEndpoints.bizumWebviewUrlPre,
        urlGetCMC: CMCEndpoints.getCmcUrlPre,
        urlGetNewMagic: MagicEndpoints.getNewMagicUrlPre,
        urlForgotMagic: MagicEndpoints.forgetMagicUrlPre,
        urlRestBase: InsuranceEndpoints.insurancesEndpointUrlPre,
        oauthClientId: RestEndpoints.restOauthClientIdPre,
        oauthClientSecret: RestEndpoints.restOauthClientSecretPre,
        microURL: MicroEndpoints.microUrlPre,
        click2CallURL: Click2CallEndpoints.click2CallUrlPRE,
        branchLocatorGlobile: BranchLocatorEndpoints.branchLocatorGlobile,
        insurancesPass2Url: InsuranceEndpoints.insurancesPass2EndpointUrlPre,
        pass2oauthClientId: RestEndpoints.pass2RestOauthClientIdPre,
        pass2oauthClientSecret: RestEndpoints.pass2RestOauthClientSecretPre,
        ecommerceUrl: EcommerceEndpoints.ecommerceMicroUrlPre,
        fintechUrl: FintechEndpoints.fintechUrlPre,
        santanderKeyUrl: SantanderKeyEndpoints.santanderKeyPre
    )
    static let environmentDev = BSANEnvironmentDTO(
        urlBase: GeneralEndpoints.endpointDev,
        isHttps: false,
        name: "DEV",
        urlNetInsight: GeneralEndpoints.niEndpointDev,
        urlSocius: SociusEndpoints.sociusEndpointUrlDev,
        urlBizumEnrollment: BizumEndpoints.bizumEnrollmentEndpointUrlDev,
        urlBizumWeb: BizumEndpoints.bizumWebviewUrlDev,
        urlGetCMC: CMCEndpoints.getCmcUrlDev,
        urlGetNewMagic: MagicEndpoints.getNewMagicUrlDev,
        urlForgotMagic: MagicEndpoints.forgetMagicUrlDev,
        urlRestBase: InsuranceEndpoints.insurancesEndpointUrlDev,
        oauthClientId: RestEndpoints.restOauthClientIdPre,
        oauthClientSecret: RestEndpoints.restOauthClientSecretPre,
        microURL: MicroEndpoints.microUrlPre,
        click2CallURL: Click2CallEndpoints.click2CallUrlPRE,
        branchLocatorGlobile: BranchLocatorEndpoints.branchLocatorGlobile,
        insurancesPass2Url: InsuranceEndpoints.insurancesPass2EndpointUrlDev,
        pass2oauthClientId: RestEndpoints.pass2RestOauthClientIdPre,
        pass2oauthClientSecret: RestEndpoints.pass2RestOauthClientSecretPre,
        ecommerceUrl: EcommerceEndpoints.ecommerceMicroUrlPre,
        fintechUrl: FintechEndpoints.fintechUrlPre,
        santanderKeyUrl: SantanderKeyEndpoints.santanderKeyPre
    )
    static let environmentCiber = BSANEnvironmentDTO(
        urlBase: GeneralEndpoints.endpointCiber,
        isHttps: false,
        name: "CIBER",
        urlNetInsight: GeneralEndpoints.niEndpointCiber,
        urlSocius: SociusEndpoints.sociusEndpointUrlCiber,
        urlBizumEnrollment: BizumEndpoints.bizumEnrollmentEndpointUrlCiber,
        urlBizumWeb: BizumEndpoints.bizumWebviewUrlCiber,
        urlGetCMC: CMCEndpoints.getCmcUrlCiber,
        urlGetNewMagic: MagicEndpoints.getNewMagicUrlCiber,
        urlForgotMagic: MagicEndpoints.forgetMagicUrlCiber,
        urlRestBase: InsuranceEndpoints.insurancesEndpointUrlCiber,
        oauthClientId: RestEndpoints.restOauthClientIdPre,
        oauthClientSecret: RestEndpoints.restOauthClientSecretPre,
        microURL: MicroEndpoints.microUrlCiber,
        click2CallURL: Click2CallEndpoints.click2CallUrlCiber,
        branchLocatorGlobile: BranchLocatorEndpoints.branchLocatorGlobile,
        insurancesPass2Url: InsuranceEndpoints.insurancesPass2EndpointUrlCiber,
        pass2oauthClientId: RestEndpoints.pass2RestOauthClientIdPre,
        pass2oauthClientSecret: RestEndpoints.pass2RestOauthClientSecretPre,
        ecommerceUrl: EcommerceEndpoints.ecommerceMicroUrlCiber,
        fintechUrl: FintechEndpoints.fintechUrlCiber,
        santanderKeyUrl: SantanderKeyEndpoints.santanderKeyPre
    )
    static let enviromentPreWas9 = BSANEnvironmentDTO(
        urlBase: GeneralEndpoints.endPointPreWas9,
        isHttps: false,
        name: "PRE WAS9",
        urlNetInsight: GeneralEndpoints.niEndpointPre,
        urlSocius: SociusEndpoints.sociusEndpointUrlPre,
        urlBizumEnrollment: BizumEndpoints.bizumEnrollmentEndpointUrlPre,
        urlBizumWeb: BizumEndpoints.bizumWebviewUrlPre,
        urlGetCMC: CMCEndpoints.getCmcUrlPre,
        urlGetNewMagic: MagicEndpoints.getNewMagicUrlPre,
        urlForgotMagic: MagicEndpoints.forgetMagicUrlPre,
        urlRestBase: InsuranceEndpoints.insurancesEndpointUrlPre,
        oauthClientId: RestEndpoints.restOauthClientIdPre,
        oauthClientSecret: RestEndpoints.restOauthClientSecretPre,
        microURL: MicroEndpoints.microUrlPre,
        click2CallURL: Click2CallEndpoints.click2CallUrlPRE,
        branchLocatorGlobile: BranchLocatorEndpoints.branchLocatorGlobile,
        insurancesPass2Url: InsuranceEndpoints.insurancesPass2EndpointUrlPre,
        pass2oauthClientId: RestEndpoints.pass2RestOauthClientIdPre,
        pass2oauthClientSecret: RestEndpoints.pass2RestOauthClientSecretPre,
        ecommerceUrl: EcommerceEndpoints.ecommerceMicroUrlPre,
        fintechUrl: FintechEndpoints.fintechUrlPre,
        santanderKeyUrl: SantanderKeyEndpoints.santanderKeyPre
    )
}
