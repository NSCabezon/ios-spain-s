import Foundation

// MARK: - SignValidationInputParams
public struct SignValidationInputParams: Codable {
    let magicPhrase: String
    let signatureData: SignatureDataInputParams?
    public var otpData: OtpDataInputParams?
    
    enum CodingKeys: String, CodingKey {
        case magicPhrase = "token"
        case signatureData
        case otpData
    }

    public init(magicPhrase: String, signatureData: SignatureDataInputParams?, otpData: OtpDataInputParams?) {
        self.magicPhrase = magicPhrase
        self.signatureData = signatureData
        self.otpData = otpData
    }
}

// MARK: - OtpDataInputParams
public struct OtpDataInputParams: Codable {
    public let xmlOperative, codeOTP, company, language, channel: String
    public var ticketOTP: String
    public var contract: String?

    public init(codeOTP: String, ticketOTP: String, contract: String?) {
        self.codeOTP = codeOTP
        self.ticketOTP = ticketOTP
        self.contract = contract
        self.xmlOperative = "<xml><![CDATA[<?xml version=\"1.0\" encoding=\"UTF-8\"?><SUSCTJM4M><codigoMulidi>00000054</codigoMulidi></SUSCTJM4M>]]></xml>"
        self.company = "0000"
        self.language = "es_ES"
        self.channel = "RML"
    }
}

// MARK: - SignatureDataInputParams
public struct SignatureDataInputParams: Codable {
    public let positions, positionsValues: String
    public init(positions: String, positionsValues: String) {
        self.positions = positions
        self.positionsValues = positionsValues
    }
}

// MARK: - EasyPayAmortizationRequestParams
public struct EasyPayAmortizationRequestParams: Codable {
    public var cdempre: String
    public var cdempred: String
    public var centalta: String
    public var cdproduc: String
    public var cuentad: String
    public var controlOperativoContrato: String
    public var controlOperativoCliente: String
    public var clamon1: String
    public var cuotano: Int
    public var nuextcta: Int
    public var numvtoex: Int

    public init(cdempre: String, cdempred: String, centalta: String, cdproduc: String, cuentad: String, controlOperativoContrato: String, controlOperativoCliente: String, clamon1: String, cuotano: Int, nuextcta: Int, numvtoex: Int) {
        self.cdempre = cdempre
        self.cdempred = cdempred
        self.centalta = centalta
        self.cdproduc = cdproduc
        self.cuentad = cuentad
        self.controlOperativoContrato = controlOperativoContrato
        self.controlOperativoCliente = controlOperativoCliente
        self.clamon1 = clamon1
        self.cuotano = cuotano
        self.nuextcta = nuextcta
        self.numvtoex = numvtoex
    }
}
