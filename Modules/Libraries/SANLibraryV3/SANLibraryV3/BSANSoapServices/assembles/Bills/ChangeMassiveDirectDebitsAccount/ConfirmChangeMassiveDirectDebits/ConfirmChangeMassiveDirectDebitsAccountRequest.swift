//

import Foundation

class ConfirmChangeMassiveDirectDebitsAccountRequest: BSANSoapRequest<ConfirmChangeMassiveDirectDebitsAccountRequestParams, BSANSoapEmptyParser.Handler, BSANSoapEmptyResponse, BSANSoapEmptyParser> {
    
    static var serviceName = "confirmaCambioMasivoSepaLa"
    
    override var serviceName: String {
        return ConfirmChangeMassiveDirectDebitsAccountRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/RECSAN/Cambiomasdomis_la/F_recsan_cambiomasdomis_la/ACRECSANCambioMasivo/v1"
    }
    
    override var message: String {
        let contract: ContractDTO?
        if params.accountDTO?.oldContract?.bankCode == "0049" {
            contract = params.accountDTO?.oldContract
        } else {
            contract = params.accountDTO?.contract
        }
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                <idioma>
                    <IDIOMA_ISO>\(serviceLanguage(params.language))</IDIOMA_ISO>
                    <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>
                </idioma>
                <datosConexion>
                    \(params.userDataDTO.getClientChannelWithCompany())
                </datosConexion>
                <firma>
                    \(params.signature.signatureDTO.map(getSignatureXmlFormatP) ?? "")
                </firma>
                <entrada>
                    <token>\(params.signature.magicPhrase ?? "")</token>
                    <contrato>
                        <CENTRO>
                            <EMPRESA>\(contract?.bankCode ?? "")</EMPRESA>
                            <CENTRO>\(contract?.branchCode ?? "")</CENTRO>
                        </CENTRO>
                        <PRODUCTO>\(contract?.product ?? "")</PRODUCTO>
                        <NUMERO_DE_CONTRATO>\(contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                    </contrato>
                </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
