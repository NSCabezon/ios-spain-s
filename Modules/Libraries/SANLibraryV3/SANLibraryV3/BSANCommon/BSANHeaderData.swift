import Foundation

public class BSANHeaderData {
    
    static let DEFAULT_TERMINAL_ID = "iOS"
    
    /*
     * Valores standard para SanES
     */
    static let DEFAULT_LANGUAGE_SAN_ES = "es-ES"
    static let DEFAULT_LANGUAGE_ISO_SAN_ES = "es"
    static let DEFAULT_DIALECT_ISO_SAN_ES = "ES"
    static let DEFAULT_LINKED_COMPANY_SAN_ES = "0000"
    // De momento solo se utiliza para Recarga Móviles
    static let DEFAULT_LINKED_COMPANY_SAN_ES_0049 = "0049";
    
    /*
     * Valores standard para SanPB
     */
    static let DEFAULT_LANGUAGE_SAN_PB = "bp-ES"
    static let DEFAULT_LANGUAGE_ISO_SAN_PB = "bp"
    static let DEFAULT_DIALECT_ISO_SAN_PB = "ES"
    static let DEFAULT_LINKED_COMPANY_SAN_PB = "0013"
    
    /*
     * Valores standard para Bizum
     */
    static let DEFAULT_LANGUAGE_BIZUM_ES = " pi"
    static let DEFAULT_LANGUAGE_ISO_BIZUM_ES = "PI"
    static let DEFAULT_LINKED_COMPANY_BIZUM = "0049"
    
    /*
     * Valores para Consulta de CVV OTP - Usuario Retail
     */
    static let DEFAULT_LANGUAGE_OTP_ISO_SAN_ES = "es"
    static let DEFAULT_DIALECT_OTP_ISO_SAN_ES = "ES"
    static let DEFAULT_LINKED_COMPANY_OTP_SAN_ES = "0049"
    
    /*
     * Valores para Consulta de CVV OTP
     */
    static let DEFAULT_LANGUAGE_OTP_ISO_SAN_PB = "bp"
    static let DEFAULT_DIALECT_OTP_ISO_SAN_PB = "BP"
    static let DEFAULT_LINKED_COMPANY_OTP_SAN_PB = "0013"
    
    /**
     * Crea una nueva instancia de DatosCabecera con los valores adecuados para San_ES
     *
     * @param version Major release de la App
     */
    public static func newInstanceForSanES(version: String) -> BSANHeaderData {
        return BSANHeaderData(version, DEFAULT_TERMINAL_ID, DEFAULT_LANGUAGE_SAN_ES,
                              DEFAULT_LANGUAGE_ISO_SAN_ES, DEFAULT_DIALECT_ISO_SAN_ES, DEFAULT_LINKED_COMPANY_SAN_ES,
                              DEFAULT_LANGUAGE_OTP_ISO_SAN_ES, DEFAULT_DIALECT_OTP_ISO_SAN_ES, DEFAULT_LINKED_COMPANY_OTP_SAN_ES)
    }
    
    /**
     * Crea una nueva instancia de DatosCabecera con los valores adecuados para San_PB
     *
     * @param version Major release de la App
     */
    public static func newInstanceForSanPB(version: String) -> BSANHeaderData {
        return BSANHeaderData(version, DEFAULT_TERMINAL_ID, DEFAULT_LANGUAGE_SAN_PB,
                              DEFAULT_LANGUAGE_ISO_SAN_PB, DEFAULT_DIALECT_ISO_SAN_PB, DEFAULT_LINKED_COMPANY_SAN_PB,
                              DEFAULT_LANGUAGE_OTP_ISO_SAN_PB, DEFAULT_DIALECT_OTP_ISO_SAN_PB, DEFAULT_LINKED_COMPANY_OTP_SAN_PB)
    }
    
    /**
     * Crea una nueva instancia de DatosCabecera con los valores adecuados para Recarga de moviles
     *
     * @param version Major release de la App
     */
    public static func newInstanceForSanESMobileRecharge(version: String) -> BSANHeaderData {
        return BSANHeaderData(version, DEFAULT_TERMINAL_ID, DEFAULT_LANGUAGE_SAN_ES,
                              DEFAULT_LANGUAGE_ISO_SAN_ES, DEFAULT_DIALECT_ISO_SAN_ES, DEFAULT_LINKED_COMPANY_SAN_ES_0049,
                              DEFAULT_LANGUAGE_OTP_ISO_SAN_ES, DEFAULT_DIALECT_OTP_ISO_SAN_ES, DEFAULT_LINKED_COMPANY_OTP_SAN_ES)
    }
    
    public static func newInstanceForAlternativeSanPB(version: String) -> BSANHeaderData {
        return BSANHeaderData(version, DEFAULT_TERMINAL_ID, DEFAULT_LANGUAGE_SAN_PB,
                              DEFAULT_LANGUAGE_ISO_SAN_PB, DEFAULT_DIALECT_ISO_SAN_PB, DEFAULT_LINKED_COMPANY_SAN_ES_0049,
                              DEFAULT_LANGUAGE_OTP_ISO_SAN_PB, DEFAULT_DIALECT_OTP_ISO_SAN_PB, DEFAULT_LINKED_COMPANY_OTP_SAN_PB)
    }
    
    public static func newInstanceForAlternativeSanES(version: String) -> BSANHeaderData {
        return BSANHeaderData(version, DEFAULT_TERMINAL_ID, DEFAULT_LANGUAGE_SAN_ES,
                              DEFAULT_LANGUAGE_ISO_SAN_ES, DEFAULT_DIALECT_ISO_SAN_ES, DEFAULT_LINKED_COMPANY_SAN_ES_0049,
                              DEFAULT_LANGUAGE_OTP_ISO_SAN_ES, DEFAULT_DIALECT_OTP_ISO_SAN_ES, DEFAULT_LINKED_COMPANY_OTP_SAN_ES)
    }
    
    /**
     * Major release de la aplicación, por ejemplo: "1.2", "4.5"
     */
    let version: String
    /**
     * Aquí debe ir siempre "iOS".
     */
    let terminalID: String
    /**
     * Utilizado en todos los servicios antiguos y en algunos de los nuevos. Para clientes Santander debe
     * ir con el valor "es-ES", para clientes Private Banking debe ir con el
     * valor "bp-ES"
     */
    let language: String
    /**
     * Utilizado en algunos de los nuevos servicios (A partir de Private
     * Banking). En PB debe ir con el valor "bp"
     */
    let languageISO: String
    /**
     * Utilizado en algunos de los nuevos servicios (A partir de Private
     * Banking). En PB debe ir con el valor "ES"
     */
    let dialectISO: String
    /**
     * Utilizado en algunos de los nuevos servicios (A partir de Private
     * Banking). En PB debe ir con el valor "0013"
     */
    let linkedCompany: String
    /**
     * IDIOMA_ISO para determinados servicios de OTP
     */
    let languageISOOTP: String
    /**
     * DIALECTO_ISO para determinados servicios de OTP
     */
    let dialectISOOTP: String
    /**
     * EMPRESA_ASOCIADA para determinados servicios de OTP
     */
    let linkedCompanyOTP: String
    
    private init(_ version: String, _ terminalID: String, _ language: String,
                 _ languageISO: String, _ dialectISO: String, _ linkedCompany: String,
                 _ languageISOOTP: String, _ dialectISOOTP: String, _ linkedCompanyOTP: String) {
        
        self.version = version
        self.terminalID = terminalID
        self.language = language
        self.languageISO = languageISO
        self.dialectISO = dialectISO
        self.linkedCompany = linkedCompany
        self.languageISOOTP = languageISOOTP
        self.dialectISOOTP = dialectISOOTP
        self.linkedCompanyOTP = linkedCompanyOTP
    }
}
