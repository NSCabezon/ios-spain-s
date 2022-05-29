//
//  LoansRepository.swift
//  Pods
//
//  Created by Andres Aguirre Juarez on 13/10/21.
//

import Foundation
import CoreDomain
import SANSpainLibrary
import SANServicesLibrary
import CoreFoundationLib

public struct LoansDataRepository: LoansRepository {
    let environmentProvider: EnvironmentProvider
    let networkManager: NetworkClientManager
    let storage: Storage
    let configurationRepository: ConfigurationRepository

    public func getLoanDetail(_ loan: LoanRepresentable) throws -> Result<LoanDetailRepresentable, Error> {
        guard let optionalUserRepresentable = storage.get(UserDataRepresentable?.self),
              let userRepresentable = optionalUserRepresentable,
              let sessionData: SessionData = storage.get()
        else { return .failure(RepositoryError.unknown)}
        
        guard let inputLoan = loan as? LoanDTO
        else { return .failure(RepositoryError.parsing)}
        let nameSpace = "http://www.isban.es/webservices/BAMOBI/Prestamos/F_bamobi_prestamos_lip/internet/"
        let facade = "ACBAMOBIPRE"
        let request = SoapSpainRequest(
            method: "POST",
            serviceName: "detallePrestamo_LA",
            url: environmentProvider.getEnvironment().soapBaseUrl + "/SCH_BAMOBI_PRESTAMOS_ENS/ws/BAMOBI_WS_Def_Listener",
            input: GetLoanDetailRequest(loan: inputLoan)
        )
        let userDataTypes: [ConnectionDataRequestInterceptor.UserDataType] = [.withMarcoChannelAndCompanyAndMultiContract(userData: userRepresentable)]
        guard let authToken: AuthenticationTokenDto = self.storage.get() else { return .failure(RepositoryError.unknown) }
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                ConnectionDataRequestInterceptor(
                    isPB: sessionData.isPB,
                    userDataTypes: userDataTypes,
                    specialLanguageServiceNames: self.configurationRepository[\.specialLanguageServiceNames] ?? []),
                HeaderDataRequestInterceptor(
                    isPB: sessionData.isPB,
                    specialLanguageServiceNames: self.configurationRepository[\.specialLanguageServiceNames] ?? [],
                    version: self.configurationRepository[\.appInfo] ?? nil),
                BodySoapInterceptor(type: .soapenv, version: .v1, nameSpace: nameSpace, facade: facade),
                AuthorizationSoapInterceptor(token: authToken.token),
                EnvelopeSoapInterceptor(type: .soapenv, nameSpace: nameSpace, facade: facade)
            ],
            responseInterceptors: [
                SoapErrorInterceptor(errorKey: "codigoError", descriptionKey: "descripcionError")
            ]
        )
        
        let result: Result<LoanDetailDTO, Error> = response.flatMap(toXMLDecodable: LoanDetailDTO.self)
        
        switch result {
        case .success(let loanDetailDTO):
            guard let loanDetailRepresentable = loanDetailDTO as? LoanDetailRepresentable else {
                return .failure(RepositoryError.parsing)
            }
            return .success(loanDetailRepresentable)
        case .failure(let error):
            return .failure(RepositoryError.unknown)
        }
    }
    
    public func getLoanPartialAmortization(_ loan: LoanRepresentable) throws -> Result<LoanPartialAmortizationRepresentable, Error> {
        guard let optionalUserRepresentable = storage.get(UserDataRepresentable?.self),
              let userRepresentable = optionalUserRepresentable,
              let sessionData: SessionData = storage.get()
        else { return .failure(RepositoryError.unknown)}
        
        guard let inputLoan = loan as? LoanDTO
        else { return .failure(RepositoryError.parsing)}
        let nameSpace = "http://www.isban.es/webservices/PREST1/Operativa_prest_la/F_prest1_operativa_prest_la/"
        let facade = "ACPREST1OPERATIVAPREST"
        let request = SoapSpainRequest(
            method: "POST",
            serviceName: "consultaAmortizacionParcialLa",
            url: environmentProvider.getEnvironment().soapBaseUrl + "/PREST1_OPERATIVAPREST_ENS_SAN/ws/PREST1_OPERATIVAPREST_Def_Listener",
            input: GetLoanPartialAmortizationRequest(loan: inputLoan)
        )
        let userDataTypes: [ConnectionDataRequestInterceptor.UserDataType] = [.withChannelAndCompany(userData: userRepresentable)]
        guard let authToken: AuthenticationTokenDto = self.storage.get() else { return .failure(RepositoryError.unknown) }
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                ConnectionDataRequestInterceptor(isPB: sessionData.isPB, userDataTypes: userDataTypes, specialLanguageServiceNames: self.configurationRepository[\.specialLanguageServiceNames] ?? []),
                BodySoapInterceptor(type: .soapenv, version: .v1, nameSpace: nameSpace, facade: facade),
                AuthorizationSoapInterceptor(token: authToken.token),
                EnvelopeSoapInterceptor(type: .soapenv, nameSpace: nameSpace, facade: facade)
            ],
            responseInterceptors: [
                LoanDataResponseErrorInterceptor(errorKey: "codigo", descriptionKey: "mensaje"),
                LoanDataResponseErrorInterceptor(errorKey: "faultcode", descriptionKey: "faultstring")
            ]
        )
        
        let result: Result<LoanPartialAmortizationDTO, Error> = response.flatMap(toXMLDecodable: LoanPartialAmortizationDTO.self)
        
        switch result {
        case .success(let loanPartialAmortizationDTO):
            guard let loanPartialAmortizationRepresentable = loanPartialAmortizationDTO as? LoanPartialAmortizationRepresentable else {
                return .failure(RepositoryError.parsing)
            }
            return .success(loanPartialAmortizationRepresentable)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func validateLoanPartialAmortization(_ loanPartialAmortization: LoanPartialAmortizationRepresentable, amount: AmountRepresentable, amortizationType: PartialAmortizationTypeRepresentable) throws -> Result<LoanValidationRepresentable, Error> {
        
        guard let optionalUserRepresentable = storage.get(UserDataRepresentable?.self),
              let userRepresentable = optionalUserRepresentable,
              let sessionData: SessionData = storage.get()
        else { return .failure(RepositoryError.unknown)}
        
        guard let inputPartialAmortization = loanPartialAmortization as? LoanPartialAmortizationDTO,
              let inputAmortization = amount as? AmountDTO,
              let inputAmortizationType = amortizationType as? PartialAmortizationType
        else { return .failure(RepositoryError.parsing)}
        let nameSpace = "http://www.isban.es/webservices/PREST1/Operativa_prest_la/F_prest1_operativa_prest_la/"
        let facade = "ACPREST1OPERATIVAPREST"
        let request = SoapSpainRequest(
            method: "POST",
            serviceName: "validaAmortizacionParcialLa",
            url: environmentProvider.getEnvironment().soapBaseUrl + "/PREST1_OPERATIVAPREST_ENS_SAN/ws/PREST1_OPERATIVAPREST_Def_Listener",
            input: ValidateLoanPartialAmortizationRequest(amount: inputAmortization,
                                                          loanPartialAmortization: inputPartialAmortization,
                                                          amortizationType: inputAmortizationType)
        )
        let userDataTypes: [ConnectionDataRequestInterceptor.UserDataType] = [.withChannelAndCompany(userData: userRepresentable)]
        guard let authToken: AuthenticationTokenDto = self.storage.get() else { return .failure(RepositoryError.unknown) }
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                ConnectionDataRequestInterceptor(isPB: sessionData.isPB, userDataTypes: userDataTypes, specialLanguageServiceNames: self.configurationRepository[\.specialLanguageServiceNames] ?? []),
                BodySoapInterceptor(type: .soapenv, version: .v1, nameSpace: nameSpace, facade: facade),
                AuthorizationSoapInterceptor(token: authToken.token),
                EnvelopeSoapInterceptor(type: .soapenv, nameSpace: nameSpace, facade: facade)
            ],
            responseInterceptors: [
                LoanDataResponseErrorInterceptor(errorKey: "codigo", descriptionKey: "mensaje")
            ]
        )
        
        let result: Result<LoanValidationDTO, Error> = response.flatMap(toXMLDecodable: LoanValidationDTO.self)
        
        switch result {
        case .success(let loanValidationDTO):
            guard let loanValidationRepresentable = loanValidationDTO as? LoanValidationRepresentable else {
                return .failure(RepositoryError.parsing)
            }
            return .success(loanValidationRepresentable)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func confirmLoanPartialAmortization(_ loanPartialAmortization: LoanPartialAmortizationRepresentable,
                                               amortizationType: PartialAmortizationTypeRepresentable,
                                               loanValidation: LoanValidationRepresentable,
                                               signature: SignatureRepresentable,
                                               amount: AmountRepresentable) throws -> Result<Void, Error> {
        
        guard let optionalUserRepresentable = storage.get(UserDataRepresentable?.self),
              let userRepresentable = optionalUserRepresentable,
              let sessionData: SessionData = storage.get()
        else { return .failure(RepositoryError.unknown)}
        
        guard let inputloanPartialAmortization = loanPartialAmortization as? LoanPartialAmortizationDTO,
              let inputSignature = signature as? SignatureDTO,
              let inputLoanValidation = loanValidation as? LoanValidationDTO,
              let inputAmortizationType = amortizationType as? PartialAmortizationType,
              let inputAmount = amount as? AmountDTO
        else { return .failure(RepositoryError.parsing)}
        let nameSpace = "http://www.isban.es/webservices/PREST1/Operativa_prest_la/F_prest1_operativa_prest_la/"
        let facade = "ACPREST1OPERATIVAPREST"
        let request = SoapSpainRequest(
            method: "POST",
            serviceName: "confirmaAmortizacionParcialLa",
            url: environmentProvider.getEnvironment().soapBaseUrl + "/PREST1_OPERATIVAPREST_ENS_SAN/ws/PREST1_OPERATIVAPREST_Def_Listener",
            input: ConfirmLoanPartialAmortizationRequest(
                loanPartialAmortization: inputloanPartialAmortization,
                amortizationType: inputAmortizationType,
                loanValidation: inputLoanValidation,
                signature: inputSignature,
                amount: inputAmount)
        )
        let userDataTypes: [ConnectionDataRequestInterceptor.UserDataType] = [.withChannelAndCompany(userData: userRepresentable)]
        guard let authToken: AuthenticationTokenDto = self.storage.get() else { return .failure(RepositoryError.unknown) }
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                ConnectionDataRequestInterceptor(isPB: sessionData.isPB, userDataTypes: userDataTypes, specialLanguageServiceNames: self.configurationRepository[\.specialLanguageServiceNames] ?? []),
                BodySoapInterceptor(type: .soapenv, version: .v1, nameSpace: nameSpace, facade: facade),
                AuthorizationSoapInterceptor(token: authToken.token),
                EnvelopeSoapInterceptor(type: .soapenv, nameSpace: nameSpace, facade: facade)
            ],
            responseInterceptors: [
                LoanDataResponseErrorInterceptor(errorKey: "codigo", descriptionKey: "mensaje")
            ]
        )
        return response.mapToVoid()
    }
    
    public func downloadPDF(_ loanPartialAmortization: LoanPartialAmortizationRepresentable, amount: AmountRepresentable, amortizationType: PartialAmortizationTypeRepresentable) throws -> Result<LoanPdfRepresentable, Error> {
        guard let optionalUserRepresentable = storage.get(UserDataRepresentable?.self),
              let userRepresentable = optionalUserRepresentable,
              let sessionData: SessionData = storage.get()
        else { return .failure(RepositoryError.unknown)}
        
        guard let inputPartialAmortization = loanPartialAmortization as? LoanPartialAmortizationDTO,
              let inputAmortization = amount as? AmountDTO,
              let inputAmortizationType = amortizationType as? PartialAmortizationType
        else { return .failure(RepositoryError.parsing)}
        let nameSpace = "http://www.isban.es/webservices/PREST1/Operativa_prest_la/F_prest1_operativa_prest_la/"
        let facade = "ACPREST1OPERATIVAPREST"
        let request = SoapSpainRequest(
            method: "POST",
            serviceName: "consultaCondicionesPdfLa",
            url: environmentProvider.getEnvironment().soapBaseUrl + "/PREST1_OPERATIVAPREST_ENS_SAN/ws/PREST1_OPERATIVAPREST_Def_Listener",
            input: GetLoanConditionsPdfRequest(amount: inputAmortization,
                                                          loanPartialAmortization: inputPartialAmortization,
                                                          amortizationType: inputAmortizationType)
        )
        let userDataTypes: [ConnectionDataRequestInterceptor.UserDataType] = [.withChannelAndCompany(userData: userRepresentable)]
        guard let authToken: AuthenticationTokenDto = self.storage.get() else { return .failure(RepositoryError.unknown) }
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                ConnectionDataRequestInterceptor(isPB: sessionData.isPB, userDataTypes: userDataTypes, specialLanguageServiceNames: self.configurationRepository[\.specialLanguageServiceNames] ?? []),
                BodySoapInterceptor(type: .soapenv, version: .v1, nameSpace: nameSpace, facade: facade),
                AuthorizationSoapInterceptor(token: authToken.token),
                EnvelopeSoapInterceptor(type: .soapenv, nameSpace: nameSpace, facade: facade)
            ],
            responseInterceptors: [
                SoapErrorInterceptor(errorKey: "codigoError", descriptionKey: "descripcionError")
            ]
        )
        
        let result: Result<DocumentDTO, Error> = response.flatMap(toXMLDecodable: DocumentDTO.self)

        switch result {
        case .success(let documentDTO):
            guard let loanPdfRepresentable = documentDTO as? LoanPdfRepresentable else {
                return .failure(RepositoryError.parsing)
            }
            return .success(loanPdfRepresentable)
        case .failure(let error):
            return .failure(RepositoryError.unknown)
        }
    }
}

struct LoanDataResponseErrorInterceptor: NetworkResponseInterceptor {
    let errorKey: String
    let descriptionKey: String
    
    func interceptResponse(_ response: NetworkResponse) throws -> Result<NetworkResponse, Error> {
        let decoder = XMLDecoder(data: response.data)
        guard
            let errorCode: String = decoder.decode(key: self.errorKey)
        else {
            return .success(response)
        }
        let description: String? = decoder.decode(key: self.descriptionKey)
        let error = NSError(domain: "soap.response", code: Int(response.status), userInfo: [NSLocalizedDescriptionKey: description ?? errorCode])
        return .failure(RepositoryError.errorWithCode(error))
    }
}

extension LoanDetailDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        guard
            let holder: String? = decoder.decode(key: "titular"),
            let initialAmount: AmountDTO? = decoder.decode(key: "impCapitalInicial").flatMap(AmountDTO.init),
            let interestType: String? = decoder.decode(key: "tipoDeInteres"),
            let interestTypeDesc: String? = decoder.decode(key: "descTipoDeInteres"),
            let feePeriodDesc: String? = decoder.decode(key: "descPerioricidadCuotas"),
            let openingDate: Date? = decoder.decode(key: "fechaApertura", format: "yyyy-MM-dd"),
            let initialDueDate: Date? = decoder.decode(key: "fechaVencimientoInicial", format: "yyyy-MM-dd"),
            let currentDueDate: Date? = decoder.decode(key: "fechaVencimientoActual", format: "yyyy-MM-dd"),
            let linkedAccountContract: ContractDTO? = decoder.decode(key: "cuentaAsociada").map(ContractDTO.init),
            let linkedAccountDesc: String? = decoder.decode(key: "descCuentaAsociada"),
            let revocable: Bool? = decoder.decode(key: "revocable"),
            let nextInstallmentDate: Date? = decoder.decode(key: "nextInstallmentDate", format: "yyyy-MM-dd"),
            let currentInterestAmount: String? = decoder.decode(key: "currentInterestAmount")
        else {
            return nil
        }
        self.init()
        self.holder = holder
        self.initialAmount = initialAmount
        self.interestType = interestType
        self.interestTypeDesc = interestTypeDesc
        self.feePeriodDesc = feePeriodDesc
        self.openingDate = openingDate
        self.initialDueDate = initialDueDate
        self.currentDueDate = currentDueDate
        self.linkedAccountContract = linkedAccountContract
        self.linkedAccountDesc = linkedAccountDesc
        self.revocable = revocable
        self.nextInstallmentDate = nextInstallmentDate
        self.currentInterestAmount = currentInterestAmount
    }
}

extension AmountDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        guard
            let value: Decimal? = decoder.decode(key: "IMPORTE"),
            let currency: CurrencyDTO? = decoder.decode(key: "DIVISA").map(CurrencyDTO.init)
        else { return nil }
        self.init()
        self.value = value
        self.currency = currency
    }
}

extension CurrencyDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        guard
            let currencyName: String? = decoder.decode(key: "DIVISA"),
            let currencyType: CurrencyType? = CurrencyType.parse(currencyName)
        else { return nil }
        self.init(currencyName: currencyName ?? "", currencyType: currencyType ?? .other(""))
    }
}

extension CurrencyType: StringInstantiable {
    public init?(from string: String) {
        self.init(string)
    }
}

extension ContractDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        guard
            let centerDTO: CenterDTO? = decoder.decode(key: "CENTRO").map(CenterDTO.init),
            let bankCode: String? = centerDTO?.bankCode,
            let centerDecode: XMLDecoder = decoder.decode(key: "CENTRO"),
            let branchCode: String? = centerDTO?.center,
            let product: String? = decoder.decode(key: "PRODUCTO"),
            let contractNumber: String? = decoder.decode(key: "NUMERO_DE_CONTRATO")
        else {
            return nil
        }
        self.init()
        self.bankCode = bankCode
        self.branchCode = branchCode
        self.product = product
        self.contractNumber = contractNumber
    }
}

struct CenterDTO: XMLDecodable {
    public init() {}
    init?(decoder: XMLDecoder) {
        guard
            let bankCode: String? = decoder.decode(key: "EMPRESA"),
            let center: String? = decoder.decode(key: "CENTRO")
        else {
            return nil
        }
        self.init()
        self.bankCode = bankCode
        self.center = center
    }
    var center: String?
    var bankCode: String?
}

extension LoanPartialAmortizationDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        guard
            let loanContractDTO: ContractDTO? = decoder.decode(key: "prestamo").map(ContractDTO.init),
            let userContractDTO: ContractDTO? = decoder.decode(key: "contrato").map(ContractDTO.init),
            let linkedAccountContractDTO: ContractDTO? = decoder.decode(key: "cuentaAsociada").map(ContractDTO.init),
            let linkedAccountIntContractDTO: ContractDTO? = decoder.decode(key: "cuentaAsociada_int").map(ContractDTO.init),
            let numeroSecuOper_HNUOPEM: String? = decoder.decode(key: "numeroSecuOper_HNUOPEM"),
            let codProductoContrato_IDPROD: String? = decoder.decode(key: "codProductoContrato_IDPROD"),
            let codSubtipoProducto_CODSPROD: String? = decoder.decode(key: "codSubtipoProducto_CODSPROD"),
            let origenOrdenMarcajDecreto_IDORIGEN: String? = decoder.decode(key: "origenOrdenMarcajDecreto_IDORIGEN"),
            let indDevolEfectDEspAcept_INDACTE1: String? = decoder.decode(key: "indDevolEfectDEspAcept_INDACTE1"),
            let indDuplicado_INDDUP: String? = decoder.decode(key: "indDuplicado_INDDUP"),
            let indIntermediacion_INDINTER: String? = decoder.decode(key: "indIntermediacion_INDINTER"),
            let indNoAmortizaPeriodCaren_INDNAMCA: String? = decoder.decode(key: "indNoAmortizaPeriodCaren_INDNAMCA"),
            let indPrestamoConsu_INDPTCON: String? = decoder.decode(key: "indPrestamoConsu_INDPTCON"),
            let indPrestamoLeasing_INDPTLEA: String? = decoder.decode(key: "indPrestamoLeasing_INDPTLEA"),
            let indResidente_INREN: String? = decoder.decode(key: "indResidente_INREN"),
            let indGrupo_INDGRU: String? = decoder.decode(key: "indGrupo_INDGRU"),
            let indOrigenDestino_IORIDES: String? = decoder.decode(key: "indOrigenDestino_IORIDES"),
            let fechaVencimiento_FECVENC2: String? = decoder.decode(key: "fechaVencimiento_FECVENC2"),
            let fechaValor_FECVAL1: String? = decoder.decode(key: "fechaValor_FECVAL1"),
            let importeResidualLeasing_IMPDIVS4: AmountDTO? = decoder.decode(key: "importeResidualLeasing_IMPDIVS4").map(AmountDTO.init),
            let importeResidFinal_IMPDIVS5: AmountDTO? = decoder.decode(key: "importeResidFinal_IMPDIVS5").map(AmountDTO.init),
            let importeLimiteInicial_IMPDIVS1: AmountDTO? = decoder.decode(key: "importeLimiteInicial_IMPDIVS1").map(AmountDTO.init),
            let importeLimiteActual_IMPDIVS2: AmountDTO? = decoder.decode(key: "importeLimiteActual_IMPDIVS2").map(AmountDTO.init),
            let nombreMoneda_NOMMONCO: String? = decoder.decode(key: "nombreMoneda_NOMMONCO"),
            let codTecnicoAplicacion_APLICACI: String? = decoder.decode(key: "codTecnicoAplicacion_APLICACI"),
            let tipoObjetoOper_ATIPOB: String? = decoder.decode(key: "tipoObjetoOper_ATIPOB"),
            let tipoObjeto_BTIPOB: String? = decoder.decode(key: "tipoObjeto_BTIPOB"),
            let codOperaBasica_CODOPBAS: String? = decoder.decode(key: "codOperaBasica_CODOPBAS"),
            let campo1JerarquiaParticulari_EHIDOBJ1: String? = decoder.decode(key: "campo1JerarquiaParticulari_EHIDOBJ1"),
            let campo2JerarquiaParticulari_EHIDOBJ2: String? = decoder.decode(key: "campo2JerarquiaParticulari_EHIDOBJ2"),
            let codEstandarReferencia_COESTREF: String? = decoder.decode(key: "codEstandarReferencia_COESTREF"),
            let numero: String? = decoder.decode(key: "numero"),
            let tipo_EHTIPOB: String? = decoder.decode(key: "tipo_EHTIPOB"),
            let indNewMortgageLoan: String? = decoder.decode(key: "indNuevaLeyHipotecaria")
        else {
            return nil
        }
        self.init()
        self.loanContractDTO = loanContractDTO
        self.userContractDTO = userContractDTO
        self.linkedAccountContractDTO = linkedAccountContractDTO
        self.linkedAccountIntContractDTO = linkedAccountIntContractDTO
        self.numeroSecuOper_HNUOPEM = numeroSecuOper_HNUOPEM
        self.codProductoContrato_IDPROD = codProductoContrato_IDPROD
        self.codSubtipoProducto_CODSPROD = codSubtipoProducto_CODSPROD
        self.origenOrdenMarcajDecreto_IDORIGEN = origenOrdenMarcajDecreto_IDORIGEN
        self.indDevolEfectDEspAcept_INDACTE1 = indDevolEfectDEspAcept_INDACTE1
        self.indDuplicado_INDDUP = indDuplicado_INDDUP
        self.indIntermediacion_INDINTER = indIntermediacion_INDINTER
        self.indNoAmortizaPeriodCaren_INDNAMCA = indNoAmortizaPeriodCaren_INDNAMCA
        self.indPrestamoConsu_INDPTCON = indPrestamoConsu_INDPTCON
        self.indPrestamoLeasing_INDPTLEA = indPrestamoLeasing_INDPTLEA
        self.indResidente_INREN = indResidente_INREN
        self.indGrupo_INDGRU = indGrupo_INDGRU
        self.indOrigenDestino_IORIDES = indOrigenDestino_IORIDES
        self.fechaVencimiento_FECVENC2 = fechaVencimiento_FECVENC2
        self.fechaValor_FECVAL1 = fechaValor_FECVAL1
        self.importeResidualLeasing_IMPDIVS4 = importeResidualLeasing_IMPDIVS4
        self.importeResidFinal_IMPDIVS5 = importeResidFinal_IMPDIVS5
        self.importeLimiteInicial_IMPDIVS1 = importeLimiteInicial_IMPDIVS1
        self.importeLimiteActual_IMPDIVS2 = importeLimiteActual_IMPDIVS2
        self.nombreMoneda_NOMMONCO = nombreMoneda_NOMMONCO
        self.codTecnicoAplicacion_APLICACI = codTecnicoAplicacion_APLICACI
        self.tipoObjetoOper_ATIPOB = tipoObjetoOper_ATIPOB
        self.tipoObjeto_BTIPOB = tipoObjeto_BTIPOB
        self.codOperaBasica_CODOPBAS = codOperaBasica_CODOPBAS
        self.campo1JerarquiaParticulari_EHIDOBJ1 = campo1JerarquiaParticulari_EHIDOBJ1
        self.campo2JerarquiaParticulari_EHIDOBJ2 = campo2JerarquiaParticulari_EHIDOBJ2
        self.codEstandarReferencia_COESTREF = codEstandarReferencia_COESTREF
        self.numero = numero
        self.tipo_EHTIPOB = tipo_EHTIPOB
        self.indNuevaLeyHipotecaria = indNewMortgageLoan
    }
}

extension LoanValidationDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        var finantialLoss: AmountDTO?
        var compensation: AmountDTO?
        var insuranceFee: AmountDTO?
        guard
            let signature: SignatureDTO? = SignatureDTO(decoder: decoder),
            let token: String? = decoder.decode(key: "dataToken"),
            let valueDate: String? = decoder.decode(key: "fechaValor_FECVAL1"),
            let settlementAmount: AmountDTO? = decoder.decode(key: "importeLiquidacion_IMPORCOA").map(AmountDTO.init)
        else {
            return nil
        }
        if let finantialLossValue: AmountDTO? = decoder.decode(key: "importePerdidaFinanciera").map(AmountDTO.init) {
            finantialLoss = finantialLossValue
        }
        if let compensationValue: AmountDTO? = decoder.decode(key: "importeComisionAmortizacion").map(AmountDTO.init) {
            compensation = compensationValue
        }
        if let insuranceFeeValue: AmountDTO? = decoder.decode(key: "importeComisionAmortizacion").map(AmountDTO.init) {
            insuranceFee = insuranceFeeValue
        }
        
        self.init()
        self.signature = signature
        self.token = token
        self.valueDate = valueDate
        self.settlementAmount = settlementAmount
        self.finantialLossAmount = finantialLoss
        self.compensationAmount = compensation
        self.insuranceFeeAmount = insuranceFee
    }
}

extension DocumentDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        guard
            let document: String? = decoder.decode(key: "documento")
        else {
            return nil
        }
        self.init()
        self.document = document
    }
}

extension SignatureDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        guard
            let length: Int? = decoder.decode(key: "tamanoFirma"),
            let positions: [Int]? = decoder.decode(key: "posiciones", separatedBy: " ")
        else {
            return nil
        }
        self.init()
        self.length = length
        self.positions = positions
    }
}
