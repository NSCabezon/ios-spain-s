//

import Foundation

class ValidateChangeMassiveDirectDebitsAccountRequest: BSANSoapRequest<ValidateChangeMassiveDirectDebitsAccountRequestParams, ValidateChangeMassiveDirectDebitsAccountHandler, ValidateChangeMassiveDirectDebitsAccountResponse, ValidateChangeMassiveDirectDebitsAccountParser> {
    
    static var serviceName = "validaCambioMasivoSepaLa"
    
    override var serviceName: String {
        return ValidateChangeMassiveDirectDebitsAccountRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/RECSAN/Cambiomasdomis_la/F_recsan_cambiomasdomis_la/ACRECSANCambioMasivo/v1"
    }
    
    override var message: String {
        let originContract: ContractDTO?
        if params.originAccount.oldContract?.bankCode == "0049" {
            originContract = params.originAccount.oldContract
        } else {
            originContract = params.originAccount.contract
        }
        let destinationContract: ContractDTO?
        if params.destinationAccount.oldContract?.bankCode == "0049" {
            destinationContract = params.destinationAccount.oldContract
        } else {
            destinationContract = params.destinationAccount.contract
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
                    <entrada>
                        <contratoOrigen>
                            <CENTRO>
                                <EMPRESA>\(originContract?.bankCode ?? "")</EMPRESA>
                                <CENTRO>\(originContract?.branchCode ?? "")</CENTRO>
                            </CENTRO>
                            <PRODUCTO>\(originContract?.product ?? "")</PRODUCTO>
                            <NUMERO_DE_CONTRATO>\(originContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                        </contratoOrigen>
                        <contratoDestino>
                            <CENTRO>
                                <EMPRESA>\(destinationContract?.bankCode ?? "")</EMPRESA>
                                <CENTRO>\(destinationContract?.branchCode ?? "")</CENTRO>
                            </CENTRO>
                            <PRODUCTO>\(destinationContract?.product ?? "")</PRODUCTO>
                            <NUMERO_DE_CONTRATO>\(destinationContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                        </contratoDestino>
                    </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
