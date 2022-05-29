import CoreFoundationLib
import SANLegacyLibrary

class GetManagerWallDataUseCase: UseCase<GetManagerWallDataUseCaseInput, GetManagerWallDataUseCaseOkOutput, StringErrorOutput>, InbentaDataUseCaseProtocol {
    
    var nodes: [String] {
        return [DomainConstant.appConfigManagerWallUrl, DomainConstant.appConfigManagerWallCloseUrl]
    }
    
    let bsanManagersProvider: BSANManagersProvider
    let appConfigRepository: AppConfigRepository
    
    var webViewTimer: Int? {
        let timer: String = appConfigRepository.getString("timerLoadingTips") ?? "0"
        return Int(timer)
    }
    
    init(bsanManagersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.bsanManagersProvider = bsanManagersProvider
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: GetManagerWallDataUseCaseInput) throws -> UseCaseResponse<GetManagerWallDataUseCaseOkOutput, StringErrorOutput> {
        let nodesTable = getNodes()
        guard let url = nodesTable[DomainConstant.appConfigManagerWallUrl], let closeUrl = nodesTable[DomainConstant.appConfigManagerWallCloseUrl] else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let managerWallVersion = appConfigRepository.getAppConfigDecimalNode(nodeName: DomainConstant.appConfigManagerWallVersion)
        switch managerWallVersion {
        case 2:
            return .ok(GetManagerWallDataUseCaseOkOutput(configuration: try salesforceWebConfiguration(url: url, closingUrl: closeUrl)))
        default:
            return .ok(GetManagerWallDataUseCaseOkOutput(configuration: try inbentaWebConfiguration(url: url, closingUrl: closeUrl, manager: requestValues.manager)))
        }
    }
    
    // MARK: - Private
    
    private func inbentaWebConfiguration(url: String, closingUrl: String, manager: Manager?) throws -> InbentaWebViewConfiguration {
        var parameters = try getParameters(defaultSegment: "PART")
        parameters["agent"] = manager?.codGest ?? ""
        parameters.changeKey(from: "tm", to: "t")
        return InbentaWebViewConfiguration(initialURL: url,
                                           bodyParameters: parameters,
                                           closingURLs: [closingUrl],
                                           webToolbarTitleKey: "toolbar_title_speakManager",
                                           pdfToolbarTitleKey: "toolbar_title_speakManager",
                                           pdfSource: .chatInbenta)
    }
    
    private func salesforceWebConfiguration(url: String, closingUrl: String) throws -> SalesforceWebViewConfiguration {
        let token = try bsanManagersProvider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        return SalesforceWebViewConfiguration(
            initialURL: url,
            bodyParameters: [
                "token": token,
                "ch": "MPAR",
                "or": ""
            ],
            closingURLs: [closingUrl],
            webToolbarTitleKey: "toolbar_title_speakManager",
            pdfToolbarTitleKey: "toolbar_title_speakManager",
            pdfSource: nil)
    }
}

struct GetManagerWallDataUseCaseInput {
    let manager: Manager?
}

struct GetManagerWallDataUseCaseOkOutput {
    let configuration: WebViewConfiguration
}

extension Dictionary {
    mutating func changeKey(from: Key, to: Key) {
        if self[from] != nil {
            self[to] = self[from]
            self.removeValue(forKey: from)
        }
    }
}
