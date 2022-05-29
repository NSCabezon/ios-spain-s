//
//  GetManagerWallDataUseCase.swift
//  PersonalManager
//
//  Created by alvola on 12/02/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

class GetManagerWallDataUseCase: UseCase<GetManagerWallDataUseCaseInput, GetManagerWallDataUseCaseOkOutput, StringErrorOutput>, InbentaDataUseCaseProtocol {
    
    var nodes: [String] {
        return ["managerWallUrl", "managerWallCloseUrl"]
    }
    
    override func executeUseCase(requestValues: GetManagerWallDataUseCaseInput) throws -> UseCaseResponse<GetManagerWallDataUseCaseOkOutput, StringErrorOutput> {
        let bsanManagersProvider = requestValues.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let appConfigRepository = requestValues.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let nodesTable = getNodes(appConfigRepository: appConfigRepository)
        guard let url = nodesTable["managerWallUrl"], let closeUrl = nodesTable["managerWallCloseUrl"] else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let managerWallVersion = appConfigRepository.getDecimal("managerWallVersion")
        switch managerWallVersion {
        case 2:
            return .ok(GetManagerWallDataUseCaseOkOutput(configuration: try salesforceWebConfiguration(url: url, closingUrl: closeUrl, bsanManagersProvider: bsanManagersProvider)))
        default:
            return .ok(GetManagerWallDataUseCaseOkOutput(configuration: try inbentaWebConfiguration(url: url, closingUrl: closeUrl, managerCodGest: requestValues.managerCodGest, bsanManagersProvider: bsanManagersProvider)))
        }
    }
    
    // MARK: - Private
    
    private func inbentaWebConfiguration(url: String, closingUrl: String, managerCodGest: String?, bsanManagersProvider: BSANManagersProvider) throws -> InbentaWebViewConfiguration {
        var parameters = try getParameters(defaultSegment: "PART", bsanManagersProvider: bsanManagersProvider)
        parameters["agent"] = managerCodGest ?? ""
        parameters.changeKey(from: "tm", to: "t")
        return InbentaWebViewConfiguration(
            initialURL: url,
            bodyParameters: parameters,
            closingURLs: [closingUrl],
            webToolbarTitleKey: "toolbar_title_speakManager",
            pdfToolbarTitleKey: "toolbar_title_speakManager",
            pdfSource: .chatInbenta
        )
    }
    
    private func salesforceWebConfiguration(url: String, closingUrl: String, bsanManagersProvider: BSANManagersProvider) throws -> SalesforceWebViewConfiguration {
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
            pdfSource: nil
        )
    }
}

struct GetManagerWallDataUseCaseInput {
    let managerCodGest: String?
    let dependenciesResolver: DependenciesResolver
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

struct SalesforceWebViewConfiguration: WebViewConfiguration {
    let initialURL: String
    let httpMethod: HTTPMethodType = .post
    let bodyParameters: [String: String]?
    let closingURLs: [String]
    let webToolbarTitleKey: String?
    let pdfToolbarTitleKey: String?
    let pdfSource: PdfSource?
    let engine: WebViewConfigurationEngine = .webkit
    let isCachePdfEnabled: Bool = false
    let isFullScreenEnabled: Bool? = false
    var reloadSessionOnClose: Bool = false
}

struct InbentaWebViewConfiguration: WebViewConfiguration {
    let initialURL: String
    let httpMethod: HTTPMethodType = .post
    let bodyParameters: [String: String]?
    let closingURLs: [String]
    let webToolbarTitleKey: String?
    let pdfToolbarTitleKey: String?
    let pdfSource: PdfSource?
    let engine: WebViewConfigurationEngine = .custom(engine: "uiwebview")
    let isCachePdfEnabled: Bool = true
    let isFullScreenEnabled: Bool? = false
    var reloadSessionOnClose: Bool = false
}
