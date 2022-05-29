import Foundation

public class ConfirmFundTransferRequest: BSANSoapRequest <ConfirmFundTransferRequestParams, ConfirmFundTransferHandler, BSANSoapResponse, ConfirmFundTransferParser> {
    
    public static let serviceName = "confirmaTraspasoFondoSAN_LA"
    
    public override var serviceName: String {
        return ConfirmFundTransferRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/FONDO1/Suscripfondos_la/F_fondo1_suscripfondos_la/internet/"
    }
    
    override var message: String {
        let dateString: String
        if let valueDate = params.valueDate {
            dateString = DateFormats.toString(date: valueDate, output: DateFormats.TimeFormat.DDMMYYYY)
        } else {
            dateString = ""
        }
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            
            "           <entrada>" +
            "               <tokenPasos>\((params.tokenPasos))</tokenPasos>" +
            XMLHelper.getContractXML(parentKey: "contratoDestino",
                                     company: params.destinationBankCode,
                                     branch: params.destinationBranchCode,
                                     product: params.destinationProduct,
                                     contractNumber: params.destinationContractNumber) +
            "               <datosFirma>\(FieldsUtils.getSignatureXml(signatureDTO: params.signatureDTO))</datosFirma>" +
            "           <datosSalidaVal>" +
            "               <numPersonaAcceso>" +
            "                   <TIPO_DE_PERSONA>\(params.personType)</TIPO_DE_PERSONA>" +
            "                   <CODIGO_DE_PERSONA>\(params.personCode)</CODIGO_DE_PERSONA>" +
            "               </numPersonaAcceso>" +
            "               <codigoFondoDestino>\((params.destinationFundCode))</codigoFondoDestino>" +
            "               <nombreFondoDestino>\((params.destinationFundName))</nombreFondoDestino>" +
            "               <fechaValor>\(dateString)</fechaValor>" +
            "               <tipoTraspasoSegunGestora>\((params.transferTypeByManagingCompany))</tipoTraspasoSegunGestora>" +
            "               <cantidadPorRepartir>\((params.quantityToSplit))</cantidadPorRepartir>" +
            "               <cantidadTraspasoParcial>\((params.partialTransferQuantity))</cantidadTraspasoParcial>" +
            "               <codigoIsinOrigen>\((params.originIsinCode))</codigoIsinOrigen>" +
            "               <codigoCifGestoraOrigen>\((params.originManagingCompanyCIF))</codigoCifGestoraOrigen>" +
            "               <contador>\((params.counter))</contador>" +
            XMLHelper.getAmountXML(parentKey: "importeDispMonedaFondo",
                                   importe: "+\(params.availableAmountValueWS)",
                                   divisa: params.availableAmountCurrency) +
            "               <participacionesFondo>\((params.sharesNumber))</participacionesFondo>" +
            "               <participacionesTraspaso>\((params.transferShares))</participacionesTraspaso>" +
            "               <saldoParticipacionesDebe>\((params.debitSharesBalance))</saldoParticipacionesDebe>" +
            "           </datosSalidaVal>" +
            XMLHelper.getContractXML(parentKey: "contratoOrigen",
                                     company: params.originBankCode,
                                     branch: params.originBranchCode,
                                     product: params.originProduct,
                                     contractNumber: params.originContractNumber) +
            XMLHelper.getFundOperationsTypeXML(parentKey: "participacionOImporte",
                                               fundOperationsType: params.operationsType) +
            XMLHelper.getAmountXML(parentKey: "importeTraspaso",
                                   importe: params.amountForWS,
                                   divisa: params.currencyWorkaround) +
            "               <tipoTraspasoTotalParcial>\((params.fundTransferType == FundTransferType.typeTotal) ? "T" : "P")</tipoTraspasoTotalParcial>" +
            "          </entrada>" +
            
            "          <datosConexion>\(params.userDataDTO.getClientChannelCmcXml)</datosConexion>" +
            XMLHelper.getHeaderData(language: serviceLanguage(params.language),
                                    dialect: params.dialect,
                                    linkedCompany: BSANHeaderData.DEFAULT_LINKED_COMPANY_SAN_ES_0049) +
            
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
