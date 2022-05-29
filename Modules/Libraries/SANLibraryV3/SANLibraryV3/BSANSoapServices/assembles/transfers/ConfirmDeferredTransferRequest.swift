import CoreDomain
import Foundation
import SANServicesLibrary

public class ConfirmDeferredTransferRequest: BSANSoapRequest<ConfirmDeferredTransferRequestParams, BSANSoapEmptyParser.Handler, BSANSoapEmptyResponse, BSANSoapEmptyParser>, SoapBodyConvertible {
    
    private static let SERVICE_NAME = "confirmaDiferidasSepaLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Periodicas_la/F_trasan_periodicas_la/"
    }
    
    public override var serviceName: String {
        return ConfirmDeferredTransferRequest.SERVICE_NAME
    }
    
    override var message: String {
        let dateNextExecution: String
        if let date = params.dateNextExecution?.date {
            dateNextExecution = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            dateNextExecution = ""
        }
        
        return """
            <soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"
            xmlns:v1=\"\(nameSpace)\(facade)/v1\">
                <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>
                <soapenv:Body>
                    <v1:\(serviceName) facade=\"\(facade)\">
                        <datosConexion>
                            <idioma>
                                <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>
                                <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>
                            </idioma>
                        \(params.userDataDTO.getUserDataWithChannelAndCompanyAndMultiContract)
                        </datosConexion>
                        <entrada>
                            <nombreCompletoBeneficiario>\(params.beneficiary)</nombreCompletoBeneficiario>
                            <indicadorResidenciaDestinatario>\(params.indicatorResidence ? "S" : "N")</indicadorResidenciaDestinatario>
                            <concepto>\(params.concept ?? "")</concepto>
                            <fechaProximaEjecucion>\(dateNextExecution)</fechaProximaEjecucion>
                            <divisaCtoOrd>\(params.currency)</divisaCtoOrd>
                            <codigoActuante>
                                <TIPO_DE_ACTUANTE>
                                    <EMPRESA>\(params.actuanteCompany)</EMPRESA>
                                    <COD_TIPO_DE_ACTUANTE>\(params.actuanteCode)</COD_TIPO_DE_ACTUANTE>
                                </TIPO_DE_ACTUANTE>
                                <NUMERO_DE_ACTUANTE>\(params.actuanteNumber)</NUMERO_DE_ACTUANTE>
                            </codigoActuante>
                            <indicadorAltaPayee>\(params.saveAsUsual ? "S" : "N")</indicadorAltaPayee>
                            <alias>\(params.saveAsUsualAlias.uppercased())</alias>
                            <token>\(params.dataToken)</token>
                            <ticket>\(params.ticketOTP)</ticket>
                            <codigoOtp>\(params.codeOTP)</codigoOtp>
                        </entrada>
                        \(getTrusteerData(params.trusteerInfo, withUrl: "/mobile/TransferenciaDiferidaSEPA"))
                    </v1:\(serviceName)>
                </soapenv:Body>
            </soapenv:Envelope>
            """
    }
}

public struct ConfirmDeferredTransferRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let dialectISO: String
    public let languageISO: String
    public let beneficiary: String
    public let trusteerInfo: TrusteerInfoDTO?
    
    public let indicatorResidence: Bool
    public let concept: String?
    public let dateNextExecution: DateModel?
    public let currency: String
    
    public let actuanteCompany: String
    public let actuanteCode: String
    public let actuanteNumber: String
    public let saveAsUsual: Bool
    public let saveAsUsualAlias: String
    public let dataToken: String
    public let ticketOTP: String
    public let codeOTP: String
}
