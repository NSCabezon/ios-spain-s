public class ConfirmationNoSEPARequest: BSANSoapRequest<ConfirmationNoSEPARequestParams, ConfirmationNoSEPAHandler, ConfirmationNoSEPAResponse, ConfirmationNoSEPAParser> {
    
    private static let SERVICE_NAME = "confirmacionIntNoSEPA_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Emisioninter_la/F_trasan_emisioninter_la/"
    }
    
    public override var serviceName: String {
        return ConfirmationNoSEPARequest.SERVICE_NAME
    }
    
    override var message: String {
        let typeTransfer: String = params.noSepaTransferInput.type?.getType() ?? "N"
        let dateOperation: String
        if let date = params.noSepaTransferInput.dateOperation?.date {
            dateOperation = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            dateOperation = ""
        }
        let accountDestination = params.noSepaTransferInput.beneficiaryAccount.account34
        return """
        <soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"
        xmlns:v1=\"\(nameSpace)\(facade)/v1\">
            <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade=\"\(facade)\">
                    <cabecera>
                        <idioma>
                            <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>
                            <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>
                        </idioma>
                        <empresaAsociada>\(params.userDataDTO.company ?? "")</empresaAsociada>
                    </cabecera>
                    <datosConexion>\(params.userDataDTO.datosUsuario)</datosConexion>
                    <entrada>
                        <bancoNoSepa>
                            <nombre>\(params.noSepaTransferInput.beneficiaryAccount.bankData?.name ?? "")</nombre>
                            <bic>\(params.validationSwiftDTO?.beneficiaryBic ?? "")</bic>
                            <pais>\(params.countryCode ?? "")</pais>
                            <nombrePais>\(params.noSepaTransferInput.beneficiaryAccount.bankData?.country ?? "")</nombrePais>
                            <localidad>\(params.noSepaTransferInput.beneficiaryAccount.bankData?.location ?? "")</localidad>
                            <domicilio>
                                <FORMATO_DOMICILIO></FORMATO_DOMICILIO>
                                <DETALLE_DOMICILIO></DETALLE_DOMICILIO>
                            </domicilio>
                        </bancoNoSepa>
                        <impOperacion>
                            <IMPORTE>\(AmountFormats.getValueForWS(value: params.validationIntNoSepaDTO.impNominalOperacion?.value))</IMPORTE>
                            <DIVISA>\(params.validationIntNoSepaDTO.impNominalOperacion?.currency?.currencyName ?? "")</DIVISA>
                        </impOperacion>
                        <fechaEmision>\(dateOperation)</fechaEmision>
                        <indResidencia>\(params.noSepaTransferInput.indicatorResidence ? "S" : "N")</indResidencia>
                        <concepto>\(params.noSepaTransferInput.concept ?? "")</concepto>
                        <cuentaBeneficiario>\(accountDestination)</cuentaBeneficiario>
                        <bic>\(params.validationSwiftDTO?.beneficiaryBic ?? "")</bic>
                        <tipoCuentaInt>\(params.noSepaTransferInput.accountType)</tipoCuentaInt>
                        <codPaisDestino>\(params.noSepaTransferInput.countryCode)</codPaisDestino>
                        <indUrgencia>\(typeTransfer)</indUrgencia>
                        <divisaOrdenante>\(params.noSepaTransferInput.originAccountDTO.currency?.currencyName ?? "")</divisaOrdenante>
                        <indGastos>\(params.noSepaTransferInput.expensiveIndicator.name)</indGastos>
                        <bancoAgenteFinan></bancoAgenteFinan>
                        <idActuanteBeneficiario>
                            <TIPO_DE_ACTUANTE>
                                <EMPRESA>\(params.validationIntNoSepaDTO.benefActing?.bankCode ?? "")</EMPRESA>
                                <COD_TIPO_DE_ACTUANTE>\(params.validationIntNoSepaDTO.benefActing?.actingTypeCode ?? "")</COD_TIPO_DE_ACTUANTE>
                            </TIPO_DE_ACTUANTE>
                            <NUMERO_DE_ACTUANTE>\(params.validationIntNoSepaDTO.benefActing?.actingNumber ?? "")</NUMERO_DE_ACTUANTE>
                        </idActuanteBeneficiario>
                        <indicadorAltaPayee>\(params.newPayee ? "S" : "N")</indicadorAltaPayee>
                        <aliasPayee>\(params.aliasPayee ?? "")</aliasPayee>
                        <codigoOTP>\(params.otpCode)</codigoOTP>
                        <token>\(params.otpValidationDTO.magicPhrase ?? "")</token>
                        <ticket>\(params.otpValidationDTO.ticket ?? "")</ticket>
                        <cuentaOrdenante>
                            <CENTRO>
                                <EMPRESA>\(params.noSepaTransferInput.originAccountDTO.oldContract?.bankCode ?? "")</EMPRESA>
                                <CENTRO>\(params.noSepaTransferInput.originAccountDTO.oldContract?.branchCode ?? "")</CENTRO>
                            </CENTRO>
                            <PRODUCTO>\(params.noSepaTransferInput.originAccountDTO.oldContract?.product ?? "")</PRODUCTO>
                            <NUMERO_DE_CONTRATO>\(params.noSepaTransferInput.originAccountDTO.oldContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                        </cuentaOrdenante>
                        <nombreBeneficiario>\(params.noSepaTransferInput.beneficiary)</nombreBeneficiario>
                        <mailCopia>\(params.beneficiaryEmail ?? "")</mailCopia>
                        <actuanteAgenteFinanciero>
                            <TIPO_DE_ACTUANTE>
                                <EMPRESA>\(params.validationIntNoSepaDTO.financialAgentActing?.bankCode ?? "")</EMPRESA>
                                <COD_TIPO_DE_ACTUANTE>\(params.validationIntNoSepaDTO.financialAgentActing?.actingTypeCode ?? "")</COD_TIPO_DE_ACTUANTE>
                            </TIPO_DE_ACTUANTE>
                            <NUMERO_DE_ACTUANTE>\(params.validationIntNoSepaDTO.financialAgentActing?.actingNumber ?? "")</NUMERO_DE_ACTUANTE>
                        </actuanteAgenteFinanciero>
                        <tipoCuentaInt>\(params.noSepaTransferInput.accountType)</tipoCuentaInt>
                        <refAcelera>\(params.refAcelera)</refAcelera>
                        <indAutoFX>S</indAutoFX>
                        <indAcelera>A</indAcelera>
                    </entrada>
                    \(getTrusteerData(params.trusteerInfo, withUrl: "/mobile/TransferenciaInterNOSEPA"))
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}

public struct ConfirmationNoSEPARequestParams {
    public let otpCode: String
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    public let noSepaTransferInput: NoSEPATransferInput
    public let validationIntNoSepaDTO: ValidationIntNoSepaDTO
    public let validationSwiftDTO: ValidationSwiftDTO?
    public let otpValidationDTO: OTPValidationDTO
    public let beneficiaryEmail: String?
    public let countryCode: String?
    public let aliasPayee: String?
    public let newPayee: Bool
    public let refAcelera: String
    public let trusteerInfo: TrusteerInfoDTO?
}
