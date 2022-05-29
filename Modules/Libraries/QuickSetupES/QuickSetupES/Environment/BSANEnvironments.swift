import SANLegacyLibrary

public struct BSANEnvironments {
    
    static let endpointPro = "https://www.bsan.mobi"
    static let endpointOcu = "https://wwwocu.bsan.mobi"
    static let endpointPre = "https://movilidad.santander.pre.corp"
    static let endpointDev = "https://desextranet.isban.dev.corp"
    static let endpointCiber = "http://10.4.0.52:8080/ciber/pre/tunel"
    static let endPointPreWas9 = "https://movretail.santander.pre.corp"
    
    static let niEndpointPro = "https://www.bsan.mobi/Estatico/ntpagetag.gif"
    static let niEndpointOcu = "https://wwwocu.bsan.mobi/Estatico/ntpagetag.gif"
    static let niEndpointPre = "https://movilidad.santander.pre.corp/Estatico/ntpagetag.gif"
    static let niEndpointDev = "https://wwwocu.bsan.mobi/Estatico/ntpagetag.gif"
    static let niEndpointCiber = "http://10.4.0.52:8080/ciber/pre/nitunel"
    
    static let sociusEndpointUrlPro = "https://adn.bsan.mobi"
    static let sociusEndpointUrlOcu = "https://adn.bsan.mobi"
    static let sociusEndpointUrlPre = "http://nuevoportalcliente.pru.bsch/adn-ws-socius-s/ADNCalSOCPortS"
    static let sociusEndpointUrlDev = "http://nuevoportalcliente.pru.bsch/adn-ws-socius-s/ADNCalSOCPortS"
    static let sociusEndpointUrlCiber = "http://10.4.0.52:8080/ciber/pre/sociustunel"
    
    static let bizumEnrollmentEndpointUrlPro = "https://pagosinmediatos.santander.pre.corp"
    static let bizumEnrollmentEndpointUrlOcu = "https://pagosinmediatos.santander.pre.corp"
    static let bizumEnrollmentEndpointUrlPre = "https://pagosinmediatos.santander.pre.corp"
    static let bizumEnrollmentEndpointUrlDev = "https://pagosinmediatos.santander.pre.corp"
    static let bizumEnrollmentEndpointUrlCiber = "http://10.4.0.52:8080/ciber/pre/altatunel"
    
    static let bizumWebviewUrlCiber = "http://10.4.0.52:8080/ciber/pre/altatunel/PAINOP_BIZUMWEB/index.jsp"
    static let bizumWebviewUrlPre = "https://pagosinmediatos.santander.pre.corp/PAINOP_BIZUMWEB/index.jsp"
    static let bizumWebviewUrlPro = "https://pagosinmediatos.bancosantander.es/PAINOP_BIZUMWEB/index.jsp"
    static let bizumWebviewUrlDev: String? = nil
    static let bizumWebviewUrlOcu = "https://pagosinmediatosocu.bancosantander.es/PAINOP_BIZUMWEB/index.jsp"
    
    static let getCmcUrlCiber: String? = nil
    static let getCmcUrlPre: String? = nil
    static let getCmcUrlPro = "https://cmc.bancosantander.es/ALTCMC_PHOENIX"
    static let getCmcUrlDev: String? = nil
    static let getCmcUrlOcu: String? = nil
	
	// Recover magic -> Principal screen
    static let forgetPasswordUrlCiber: String? = nil
    static let forgetPasswordUrlPre = "https://cmc.santander.pre.corp/REGCLA_PHOENIX/static/index.html?sty=APP"
    static let forgetPasswordUrlPro = "https://cmc.bancosantander.es/REGCLA_PHOENIX/static/index.html?sty=APP"
    static let forgetPasswordUrlDev: String? = nil
    static let forgetPasswordUrlOcu = "https://cmcocu.bancosantander.es/REGCLA_PHOENIX/static/index.html?sty=APP"

	// Recover magic -> Lateral drawer
    static let getNewPasswordUrlCiber: String? = nil
    static let getNewPasswordUrlPre = "https://cmc.santander.pre.corp/REGCLA_PHOENIX/static/index.html?sty=APP"
    static let getNewPasswordUrlPro = "https://cmc.bancosantander.es/REGCLA_PHOENIX/static/index.html?sty=APP"
    static let getNewPasswordUrlDev: String? = nil
    static let getNewPasswordUrlOcu = "https://cmcocu.bancosantander.es/REGCLA_PHOENIX/static/index.html?sty=APP"
    
    static let insurancesEndpointUrlPro = "https://api.bancosantander.es/canales-digitales/internet-pro/"
    static let insurancesEndpointUrlOcu: String? = "https://api.bancosantander.es/canales-digitales/internet-pro/"
    static let insurancesEndpointUrlPre = "https://apigateway-internet.santander.pre.corp/canales-digitales/internet/"
    static let insurancesEndpointUrlDev: String? = nil
    static let insurancesEndpointUrlCiber = "http://10.4.0.52:8080/ciber/pre/apirest/"
    
    static let insurancesPaas2EndpointUrlPro = "https://apis.bancosantander.es/canales-digitales/internet"
    static let insurancesPass2EndpointUrlOcu = "https://apis.bancosantander.es/canales-digitales/internet"
    static let insurancesPass2EndpointUrlPre = "https://apigtw-sanes-internet.santander.pre.corp/canales-digitales/internet"
    static let insurancesPass2EndpointUrlDev = "https://apigtw-sanes-internet.santander.pre.corp/canales-digitales/internet"
    static let insurancesPass2EndpointUrlCiber: String? = nil
    
    static let restOauthClientIdPre = "119285e3-841c-4d2c-b831-19911bf91343"
    static let restOauthClientSecretPre = "dU6rX8iX7yQ3xB7gI7pN7dI6oW0tM0tD2wX4jU7eP4uI3mP0eF"
    static let restOauthClientIdPro = "977875fa-a091-499c-8bad-c7cb3b075df5"
    static let restOauthClientSecretPro = "A1bF8vK0mI2oV6lE7eH4pY7vH4kI7mC5uN2fW7vW4dO6pE7uE6"
    static let pass2RestOauthClientIdPro = "634bba61-055a-4298-8b0d-dead446a358a"
    static let pass2RestOauthClientSecretPro = "kW2gB3fS8oH4iF7iM6yI8aJ1rH4lE7nD3xJ5jH8oC2wG5vR8fB"
    static let pass2RestOauthClientIdPre = "4a4fa5a5-2a08-4bb3-9fd3-ebbe79c4567a"
    static let pass2RestOauthClientSecretPre = "H3hJ6yA3yB0mK7wG8dH7lQ0iT8bA6tQ1fH5uT7uP4tR7dV2xV5"
    
    static let bizumWebViewUrlPro = "https://pagosinmediatos.bancosantander.es/PAINOP_BIZUMWEB/index.jsp"
    static let bizumWebViewUrlPre = "https://pagosinmediatos.santander.pre.corp/PAINOP_BIZUMWEB/index.jsp"
    static let bizumWebViewUrlOcu = "https://pagosinmediatosocu.bancosantander.es/PAINOP_BIZUMWEB/index.jsp"
    
    static let microUrlPre = "https://sanesp-pre.pru.bsch"
    static let microUrlOcu = "https://sanespmobi-ocu.corp.bsch"
    static let microUrlPro = "https://sanesp.mobi"
    
    static let click2CallUrlPRE = "https://click2callapp.pru.bsch/c2c/api/app/"
    static let click2CallUrlPRO = "https://click2call.gruposantander.es/c2c/api/app/"
    
    static let branchLocatorGlobile = "https://back-weu.azurewebsites.net"

    static let ecommerceMicroUrlPre = "https://scammppweb.pru.bsch"
    static let ecommerceMicroUrlPro = "https://scaweb.bsan.mobi"

    static let fintechUrlPre = "https://apigtw-sanes-internet.santander.pre.corp"
    static let fintechUrlPro = "https://apis.bancosantander.es"

    public static let environmentPro = BSANEnvironmentDTO(
        urlBase: endpointPro,
        isHttps: false,
        name: "PRO",
        urlNetInsight: niEndpointPro,
        urlSocius: sociusEndpointUrlPro,
        urlBizumEnrollment: bizumEnrollmentEndpointUrlPro,
        urlBizumWeb: bizumWebviewUrlPro,
        urlGetCMC: getCmcUrlPro,
        urlGetNewMagic: getNewPasswordUrlPro,
        urlForgotMagic: forgetPasswordUrlPro,
        urlRestBase: insurancesEndpointUrlPro,
        oauthClientId: restOauthClientIdPro,
        oauthClientSecret: restOauthClientSecretPro,
        microURL: microUrlPro,
        click2CallURL: click2CallUrlPRO,
        branchLocatorGlobile: branchLocatorGlobile,
        insurancesPass2Url: insurancesPaas2EndpointUrlPro,
        pass2oauthClientId: pass2RestOauthClientIdPro,
        pass2oauthClientSecret: pass2RestOauthClientSecretPro,
        ecommerceUrl: ecommerceMicroUrlPro,
        fintechUrl: fintechUrlPro
    )

    public static let environmentPre = BSANEnvironmentDTO(
        urlBase: endpointPre,
        isHttps: false,
        name: "PRE",
        urlNetInsight: niEndpointPre,
        urlSocius: sociusEndpointUrlPre,
        urlBizumEnrollment: bizumEnrollmentEndpointUrlPre,
        urlBizumWeb: bizumWebviewUrlPre,
        urlGetCMC: getCmcUrlPre,
        urlGetNewMagic: getNewPasswordUrlPre,
        urlForgotMagic: forgetPasswordUrlPre,
        urlRestBase: insurancesEndpointUrlPre,
        oauthClientId: restOauthClientIdPre,
        oauthClientSecret: restOauthClientSecretPre,
        microURL: microUrlPre,
        click2CallURL: click2CallUrlPRE,
        branchLocatorGlobile: branchLocatorGlobile,
        insurancesPass2Url: insurancesPass2EndpointUrlPre,
        pass2oauthClientId: pass2RestOauthClientIdPre,
        pass2oauthClientSecret: pass2RestOauthClientSecretPre,
        ecommerceUrl: ecommerceMicroUrlPre,
        fintechUrl: fintechUrlPre
    )
    public static let environmentDev = BSANEnvironmentDTO(
        urlBase: endpointDev,
        isHttps: false,
        name: "DEV",
        urlNetInsight: niEndpointDev,
        urlSocius: sociusEndpointUrlDev,
        urlBizumEnrollment: bizumEnrollmentEndpointUrlDev,
        urlBizumWeb: bizumWebviewUrlDev,
        urlGetCMC: getCmcUrlDev,
        urlGetNewMagic: getNewPasswordUrlDev,
        urlForgotMagic: forgetPasswordUrlDev,
        urlRestBase: insurancesEndpointUrlDev,
        oauthClientId: restOauthClientIdPre,
        oauthClientSecret: restOauthClientSecretPre,
        microURL: microUrlPre,
        click2CallURL: click2CallUrlPRE,
        branchLocatorGlobile: branchLocatorGlobile,
        insurancesPass2Url: bizumEnrollmentEndpointUrlDev,
        pass2oauthClientId: pass2RestOauthClientIdPre,
        pass2oauthClientSecret: pass2RestOauthClientSecretPre,
        ecommerceUrl: ecommerceMicroUrlPre,
        fintechUrl: fintechUrlPre
    )
    public static let environmentCiber = BSANEnvironmentDTO(
        urlBase: endpointCiber,
        isHttps: false,
        name: "CIBER",
        urlNetInsight: niEndpointCiber,
        urlSocius: sociusEndpointUrlCiber,
        urlBizumEnrollment: bizumEnrollmentEndpointUrlCiber,
        urlBizumWeb: bizumWebviewUrlCiber,
        urlGetCMC: getCmcUrlCiber,
        urlGetNewMagic: getNewPasswordUrlCiber,
        urlForgotMagic: forgetPasswordUrlCiber,
        urlRestBase: insurancesEndpointUrlCiber,
        oauthClientId: restOauthClientIdPre,
        oauthClientSecret: restOauthClientSecretPre,
        microURL: microUrlPre,
        click2CallURL: click2CallUrlPRE,
        branchLocatorGlobile: branchLocatorGlobile,
        insurancesPass2Url: insurancesPass2EndpointUrlCiber,
        pass2oauthClientId: pass2RestOauthClientIdPre,
        pass2oauthClientSecret: pass2RestOauthClientSecretPre,
        ecommerceUrl: ecommerceMicroUrlPre,
        fintechUrl: fintechUrlPre
    )
    public static let enviromentPreWas9 = BSANEnvironmentDTO(
        urlBase: endPointPreWas9,
        isHttps: false,
        name: "PRE WAS9",
        urlNetInsight: niEndpointPre,
        urlSocius: sociusEndpointUrlPre,
        urlBizumEnrollment: bizumEnrollmentEndpointUrlPre,
        urlBizumWeb: bizumWebviewUrlPre,
        urlGetCMC: getCmcUrlPre,
        urlGetNewMagic: getNewPasswordUrlPre,
        urlForgotMagic: forgetPasswordUrlPre,
        urlRestBase: insurancesEndpointUrlPre,
        oauthClientId: restOauthClientIdPre,
        oauthClientSecret: restOauthClientSecretPre,
        microURL: microUrlPre,
        click2CallURL: click2CallUrlPRE,
        branchLocatorGlobile: branchLocatorGlobile,
        insurancesPass2Url: insurancesPass2EndpointUrlPre,
        pass2oauthClientId: pass2RestOauthClientIdPre,
        pass2oauthClientSecret: pass2RestOauthClientSecretPre,
        ecommerceUrl: ecommerceMicroUrlPre,
        fintechUrl: fintechUrlPre
    )
    public static let environmentOcu = BSANEnvironmentDTO(
        urlBase: endpointOcu,
        isHttps: false,
        name: "OCU",
        urlNetInsight: niEndpointOcu,
        urlSocius: sociusEndpointUrlOcu,
        urlBizumEnrollment: bizumEnrollmentEndpointUrlOcu,
        urlBizumWeb: bizumWebviewUrlOcu,
        urlGetCMC: getCmcUrlOcu,
        urlGetNewMagic: getNewPasswordUrlOcu,
        urlForgotMagic: forgetPasswordUrlOcu,
        urlRestBase: insurancesEndpointUrlOcu,
        oauthClientId: restOauthClientIdPro,
        oauthClientSecret: restOauthClientSecretPro,
        microURL: microUrlOcu,
        click2CallURL: click2CallUrlPRO,
        branchLocatorGlobile: branchLocatorGlobile,
        insurancesPass2Url: insurancesPass2EndpointUrlOcu,
        pass2oauthClientId: pass2RestOauthClientIdPro,
        pass2oauthClientSecret: pass2RestOauthClientSecretPro,
        ecommerceUrl: ecommerceMicroUrlPro,
        fintechUrl: fintechUrlPro
    )
}
