struct TransferSubTypeComissionRequestParams: Codable {

    let beneficiaryName: String
    let originAccountNumber: String
    let originAccountOwner: String
    let destinationAccountNumber: String
    let destinationAccountCountry: String
    let destinationAccountDigit: String
    let amountWholeNumberPart: String
    let amountFractionalPart: String
    let concept: String
    let multichannelContract: String
    let language: String
    let personType: String
    let personCode: String
    let transferType: String = ""
    let accountIndicator: String = ""
    
    enum CodingKeys: String, CodingKey {
        case beneficiaryName = "nombreBeneficiario"
        case originAccountNumber = "cuentaCargo"
        case originAccountOwner = "titularCuentaCargo"
        case destinationAccountNumber = "cuentaAbono"
        case destinationAccountCountry = "cuentaAbonoPais"
        case destinationAccountDigit = "cuentaAbonoDigito"
        case amountWholeNumberPart = "impTransferenciaEntera"
        case amountFractionalPart = "impTransferenciaDecimal"
        case concept = "conceptoTransfer"
        case multichannelContract = "contratoMulticanal"
        case language = "idioma"
        case personType = "titularTipoPers"
        case personCode = "titularCodPers"
        case transferType = "tipTransf"
        case accountIndicator = "indCtaVinculada"
    }
}

struct TransferSubTypeCommissionDataSource: TransferSubTypeCommissionDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let serviceName = "preliquidaciones"
    private let basePath = "/api/v1/envioPagos/"
    private let headers = ["X-Santander-Channel" : "RML"]
    
    init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func loadTransferTypeComissions(params: TransferSubTypeComissionRequestParams) throws -> BSANResponse<TransferSubTypeCommissionDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.basePath + self.serviceName
        return try self.executeRestCall(
            serviceName: self.serviceName,
            serviceUrl: url,
            params: params,
            contentType: .json,
            requestType: .post,
            headers: self.headers
        )
    }
}
