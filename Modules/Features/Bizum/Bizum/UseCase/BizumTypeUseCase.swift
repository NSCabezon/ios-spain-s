import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import SANSpainLibrary

public final class BizumTypeUseCase: UseCase<BizumTypeUseCaseInput, BizumTypeUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override public func executeUseCase(requestValues: BizumTypeUseCaseInput) throws -> UseCaseResponse<BizumTypeUseCaseOkOutput, StringErrorOutput> {
        do {
            if let response = try self.getBizumNative(requestValues.type), response.isOkResult {
                return response
            } else {
                return try self.executeBizumWeb(with: requestValues.webViewType)
            }
        } catch {
            return .error(StringErrorOutput(""))
        }
    }
}

private extension BizumTypeUseCase {
    func executeBizumWeb(with type: BizumWebViewType?) throws -> UseCaseResponse<BizumTypeUseCaseOkOutput, StringErrorOutput> {
        let environmentResponse = self.provider.getBsanEnvironmentsManager().getCurrentEnvironment()
        guard environmentResponse.isSuccess(), let bsanEnvironment = try provider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData(), let bizumUrl = bsanEnvironment.urlBizumWeb else {
            return UseCaseResponse.error(StringErrorOutput(try environmentResponse.getErrorMessage()))
        }
        let token = try provider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        let parameters = try self.generateParameters(with: type)
        let closingUrl = "www.bancosantander.es"
        let configuration = BizumWebViewConfiguration(initialURL: bizumUrl,
                                                      bodyParameters: parameters,
                                                      closingURLs: [closingUrl],
                                                      webToolbarTitleKey: "toolbar_title_bizum",
                                                      pdfToolbarTitleKey: "toolbar_title_bizum")
        return UseCaseResponse.ok(.web(configuration: configuration))
    }
    
    func generateParameters(with type: BizumWebViewType?) throws -> [String: String] {
        let token = try self.provider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        var parameters = [
            "token": token,
            "bizum_app_version": "2"
        ]
        if let type = type {
            switch type {
            case .donation:
                parameters["operation"] = "sendONG"
            case .qrCode:
                parameters["operation"] = "qrCode"
            case .settings:
                parameters["operation"] = "settings"
            }
        }
        return parameters
    }
    
    func getBizumNative(_ type: BizumTypeUseCaseType) throws -> UseCaseResponse<BizumTypeUseCaseOkOutput, StringErrorOutput>? {
        let appConfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
       
        let appConfigKey: String
        switch type {
        case .home:
            appConfigKey = BizumConstants.isEnableBizumNative
        case .send:
            appConfigKey = BizumConstants.isEnableSendMoneyBizumNative
        case .request:
            appConfigKey = BizumConstants.isEnableRequestMoneyBizumNative
        case .cancelNotRegister:
            appConfigKey = BizumConstants.isCancelSendMoneyForNotClientByBizum
        case .acceptRequest:
            appConfigKey = BizumConstants.isEnableAcceptRequestMoneyBizumNative
        case .refundMoney:
            appConfigKey = BizumConstants.isReturnMoneyReceivedBizumNativeEnabled
        case .cancelRequest:
            appConfigKey = BizumConstants.isCancelRequestBizumNativeEnabled
        case .rejectRequest:
            appConfigKey = BizumConstants.isRejectRequestBizumNativeEnabled
        case .splitExpenses:
            appConfigKey = BizumConstants.isSplitCostsBizumNativeEnabled
        case .donations:
            appConfigKey = BizumConstants.isEnableBizumDotations
        }
        guard appConfigRepository.getBool(appConfigKey) == true else {
            return nil
        }
        guard self.checkOperativity() else {
            return nil
        }
        guard !self.checkOTPExcepted() else {
            return nil
        }
        return try self.getBizumUserState()
    }
    
    func checkOTPExcepted() -> Bool {
        let cmpsResponse = try? self.provider.getBsanSendMoneyManager().getCMPSStatus()
        if cmpsResponse?.isSuccess() == true,
            let cmpsDTO = try? cmpsResponse?.getResponseData() {
            let cmps = CMPSEntity.createFromDTO(dto: cmpsDTO)
            return cmps.isOTPExcepted
        } else {
            return false
        }
    }
    
    func getBizumUserState() throws -> UseCaseResponse<BizumTypeUseCaseOkOutput, StringErrorOutput>? {
        let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let defaultXPAN = appConfigRepository.getString(BizumHomeConstants.bizumDefaultXPAN) ?? ""
        let response = try self.dependenciesResolver.resolve(for: BizumRepository.self).checkPayment(defaultXPAN: defaultXPAN)
        switch response {
        case .success(let checkPayment):
            if checkPayment.offsetState == "A" || checkPayment.offsetState == "N" {
                return .ok(.native(bizumCheckPayment: BizumCheckPaymentEntity(BizumCheckPaymentDTO(from: checkPayment))))
            } else {
                return nil
            }
        case .failure(let error):
            return nil
        }
    }
    
    func checkOperativity() -> Bool {
        let response = try? self.provider.getBsanSignatureManager().getCMCSignature()
        if response?.isSuccess() ==  true,
            let info = try? response?.getResponseData(),
            info.signatureDataDTO.list?.first?.userOperabilityInd?.uppercased() == "O" {
            return true
        } else {
            return false
        }
    }
}

extension BizumCheckPaymentDTO {
    
    // Temporal extension since we move all bizum services to new SANServicesLibrary
    init(from checkPayment: BizumCheckPaymentRepresentable) {
        self.init(
            phone: checkPayment.phone,
            contractIdentifier: BizumCheckPaymentContractDTO(center: CentroDTO(empresa: checkPayment.contract.center.company, centro: checkPayment.contract.center.center), subGroup: checkPayment.contract.subGroup, contractNumber: checkPayment.contract.contractNumber),
            initialDate: checkPayment.initialDate,
            endDate: checkPayment.endDate,
            back: checkPayment.back,
            message: checkPayment.message,
            ibanCode: BizumCheckPaymentIBANDTO(country: checkPayment.iban.country, controlDigit: checkPayment.iban.controlDigit, codbban: checkPayment.iban.codbban),
            offset: checkPayment.offset,
            offsetState: checkPayment.offsetState,
            indMigrad: checkPayment.indMigrad,
            xpan: checkPayment.xpan
        )
    }
}

public enum BizumTypeUseCaseType {
    case home
    case send
    case request
    case acceptRequest
    case refundMoney
    case cancelNotRegister
    case cancelRequest
    case rejectRequest
    case splitExpenses
    case donations
}

public struct BizumTypeUseCaseInput {
    let type: BizumTypeUseCaseType
    let webViewType: BizumWebViewType?
    
    public init(type: BizumTypeUseCaseType, webViewType: BizumWebViewType? = nil) {
        self.type = type
        self.webViewType = webViewType
    }
}

public enum BizumTypeUseCaseOkOutput {
    case native(bizumCheckPayment: BizumCheckPaymentEntity)
    case web(configuration: WebViewConfiguration)
}
