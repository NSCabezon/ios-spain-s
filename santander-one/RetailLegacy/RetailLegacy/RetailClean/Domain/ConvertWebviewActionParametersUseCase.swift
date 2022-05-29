import CoreFoundationLib
import SANLegacyLibrary

class ConvertWebviewActionParametersUseCase: UseCase<ConvertWebviewActionParametersUseCaseInput, ConvertWebviewActionParametersUseCaseOkOutput, StringErrorOutput> {
    private let appRepository: AppRepository
    private let provider: BSANManagersProvider
    private let dataProvider: BSANDataProviderProtocol
    private let dependencies: DependenciesResolver
    
    init(appRepository: AppRepository,
         provider: BSANManagersProvider,
         dataProvider: BSANDataProviderProtocol,
         dependencies: DependenciesResolver) {
        self.dependencies = dependencies
        self.appRepository = appRepository
        self.provider = provider
        self.dataProvider = dataProvider
    }
    
    override public func executeUseCase(requestValues: ConvertWebviewActionParametersUseCaseInput) throws -> UseCaseResponse<ConvertWebviewActionParametersUseCaseOkOutput, StringErrorOutput> {
        let parameters: [String: String] = try self.convertToDictionary(convertibles: requestValues.parameters, requestValues: requestValues)
        var headers: [String: String]?
        if let requestHeaders = requestValues.headers {
            headers = try self.convertToDictionary(convertibles: requestHeaders, requestValues: requestValues)
        }
        return UseCaseResponse.ok(ConvertWebviewActionParametersUseCaseOkOutput(parametersConversion: parameters, headersConversion: headers))
    }
}

private extension ConvertWebviewActionParametersUseCase {
    func getToken() throws -> String? {
        guard try self.appRepository.isSessionEnabled().getResponseData() ?? false else { return "" }
        return try self.provider.getBsanAuthManager().getAuthCredentials().soapTokenCredential.trim()
    }
    
    func getCompanyId() throws -> String? {
        guard try self.appRepository.isSessionEnabled().getResponseData() ?? false else { return "" }
        let response = self.appRepository.getPersistedUser()
        guard response.isSuccess(), let persistedUserDTO = try response.getResponseData() else {
            return nil
        }
        return persistedUserDTO.isPb ? "0013":"0049"
    }
    
    func getUserId() throws -> String? {
        guard let data = try self.getUserDataDTO() else { return "" }
        return UserDO(dto: data).userId?.trim()
    }
    
    func getContractId() throws -> String? {
        guard let data = try self.getUserDataDTO() else { return "" }
        return data.contract?.contratoPK?.trim()
    }
    
    func getUserName() throws -> String {
        guard try self.appRepository.isSessionEnabled().getResponseData() ?? false else { return "" }
        let response = try self.provider.getBsanPGManager().getGlobalPosition()
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return ""
        }
        return data.clientNameWithoutSurname?.trim() ?? ""
    }
    
    func getPersonCode() throws -> String? {
        guard let data = try self.getUserDataDTO() else { return "" }
        return data.clientPersonCode?.trim()
    }
    
    func getChannelFrame() throws -> String? {
        guard let data = try self.getUserDataDTO() else { return "" }
        return data.channelFrame?.trim()
    }
    
    func getTypePerson() throws -> String? {
        guard let data = try self.getUserDataDTO() else { return "" }
        return data.clientPersonType?.trim()
    }
    
    func getMultiCompany() throws -> String? {
        guard let data = try self.getUserDataDTO() else { return "" }
        return data.contract?.bankCode?.trim()
    }
    
    func getMultiCenter() throws -> String? {
        guard let data = try self.getUserDataDTO() else { return "" }
        return data.contract?.branchCode?.trim()
    }
    
    func getMultiProd() throws -> String? {
        guard let data = try self.getUserDataDTO() else { return "" }
        return data.contract?.product?.trim()
    }
    
    func getMultiNumContract() throws -> String? {
        guard let data = try self.getUserDataDTO() else { return "" }
        return data.contract?.contractNumber?.trim()
    }
    
    func getLanguageISO() throws -> String {
        return try self.dataProvider.getLanguageISO().trim()
    }
    
    func getDialectISO() throws -> String {
        return try self.dataProvider.getDialectISO().trim()
    }
    
    func getUserDataDTO() throws -> UserDataDTO? {
        guard try self.appRepository.isSessionEnabled().getResponseData() ?? false else { return nil }
        let response = try self.provider.getBsanPGManager().getGlobalPosition()
        guard response.isSuccess(), let data = try response.getResponseData()?.userDataDTO else {
            return nil
        }
        return data
    }
    
    func convertToDictionary(convertibles: [WebViewMacroCapable], requestValues: ConvertWebviewActionParametersUseCaseInput) throws -> [String: String] {
        var dictionary: [String: String] = [:]
        for convertible in convertibles {
            let uppercasedValue = convertible.value.uppercased()
            if let dynamic = OpenWebViewActionParameter(rawValue: uppercasedValue) {
                switch dynamic {
                case .token:
                    dictionary[convertible.key] = try self.getToken()
                case .companyId:
                    dictionary[convertible.key] = try self.getCompanyId()
                case .userId:
                    dictionary[convertible.key] = try self.getUserId()
                case .contractId:
                    if let contractId = requestValues.product?.contractId {
                        dictionary[convertible.key] = contractId
                    } else {
                        dictionary[convertible.key] = try self.getContractId()
                    }
                case .portfolioId:
                    dictionary[convertible.key] = requestValues.product?.portfolioId
                case .stockFundName:
                    dictionary[convertible.key] = requestValues.product?.fundName
                case .family:
                    dictionary[convertible.key] = requestValues.product?.family
                case .userName:
                    dictionary[convertible.key] = try self.getUserName()
                case .stockCode:
                    dictionary[convertible.key] = requestValues.product?.stockCode
                case .identificationNumber:
                    dictionary[convertible.key] = requestValues.product?.identificationNumber
                case .language:
                    let current: Language
                    let response = self.appRepository.getLanguage()
                    if case let languageType?? = try response.getResponseData() {
                        current = Language.createFromType(languageType: languageType, isPb: nil)
                    } else {
                        let defaultLanguage = self.dependencies.resolve(for: LocalAppConfig.self).language
                        let languageList = self.dependencies.resolve(for: LocalAppConfig.self).languageList
                        current = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList)
                    }
                    dictionary[convertible.key] = current.appLanguageCode
                case .personCode:
                    dictionary[convertible.key] = try self.getPersonCode()
                case .channelFrame:
                    dictionary[convertible.key] = try self.getChannelFrame()
                case .typePerson:
                    dictionary[convertible.key] = try self.getTypePerson()
                case .multiCompany:
                    dictionary[convertible.key] = try self.getMultiCompany()
                case .multiCenter:
                    dictionary[convertible.key] = try self.getMultiCenter()
                case .multiProd:
                    dictionary[convertible.key] = try self.getMultiProd()
                case .multiNumContract:
                    dictionary[convertible.key] = try self.getMultiNumContract()
                case .languageISO:
                    dictionary[convertible.key] = try self.getLanguageISO()
                case .dialectISO:
                    dictionary[convertible.key] = try self.getDialectISO()
                }
            } else if let provider = dependencies.resolve(forOptionalType: PullOffersWebviewMacroResolverProvider.self), let value = provider.getValueForMacro(uppercasedValue){
                dictionary[convertible.key] = value
            } else {
                dictionary[convertible.key] = convertible.value
            }
        }
        return dictionary
    }
}

struct ConvertWebviewActionParametersUseCaseInput {
    let parameters: [OfferWebViewParameter]
    let headers: [OpenWebViewHeader]?
    let product: ProductWebviewParameters?
}

struct ConvertWebviewActionParametersUseCaseOkOutput {
    let parametersConversion: [String: String]
    let headersConversion: [String: String]?
}

protocol ProductWebviewParameters {
    var fundName: String? { get }
    var portfolioId: String? { get }
    var contractId: String? { get }
    var family: String? { get }
    var stockCode: String? { get }
    var identificationNumber: String? { get }
}
