import Foundation


public class WebServicesUrlProviderImpl: WebServicesUrlProvider {
    private var bsanDataProvider: BSANDataProvider
    private var urlsForMulMov: [String] = []
    private var shouldUsePass2Urls: Bool = false
 
    public init(bsanDataProvider: BSANDataProvider) {
        self.bsanDataProvider = bsanDataProvider
    }
    
    private func getBaseUrl() throws -> String {
        if !shouldUsePass2Urls, let urlRestBase = try bsanDataProvider.getEnvironment().urlRestBase {
            return urlRestBase
        } else if shouldUsePass2Urls, let insurancesPass2Url = try bsanDataProvider.getEnvironment().insurancesPass2Url {
            return insurancesPass2Url
        }
        if bsanDataProvider.isDemo() {
            return ""
        }
        throw BSANServiceNoImplemented("")
    }
    
    public func getClientId() throws -> String {
        return !shouldUsePass2Urls ?
            try bsanDataProvider.getEnvironment().oauthClientId:
            try bsanDataProvider.getEnvironment().pass2oauthClientId
    }
    
    public func getClientSecret() throws -> String {
        return !shouldUsePass2Urls ?
            try bsanDataProvider.getEnvironment().oauthClientSecret:
            try bsanDataProvider.getEnvironment().pass2oauthClientSecret
    }
    
    public func getLoginUrl() -> String {
        do {
            return try getBaseUrl() + WebServicesUrl.LOGIN
        } catch let error {
            BSANLogger.i("WebServicesUrlProviderImpl", "FAILURE : \(#function) - \(error.localizedDescription)")
            return ""
        }
    }
    
    public func getInsuranceDataUrl(contractId: String) -> String {
        do {
            return try getBaseUrl() + String(format: WebServicesUrl.GET_INSURANCE_DATA, contractId)
        } catch let error {
            BSANLogger.i("WebServicesUrlProviderImpl", "FAILURE : \(#function) - \(error.localizedDescription)")
            return ""
        }
    }
    
    public func getParticipantsUrl(policyId: String) -> String {
        do {
            return try getBaseUrl() + String(format: WebServicesUrl.GET_PARTICIPANTS, policyId)
        } catch let error {
            BSANLogger.i("WebServicesUrlProviderImpl", "FAILURE : \(#function) - \(error.localizedDescription)")
            return ""
        }
    }
    
    public func getBeneficiariesUrl(policyId: String) -> String {
        do {
            return try getBaseUrl() + String(format: WebServicesUrl.GET_BENEFICIARIES, policyId)
        } catch let error {
            BSANLogger.i("WebServicesUrlProviderImpl", "FAILURE : \(#function) - \(error.localizedDescription)")
            return ""
        }
    }
    
    public func getCoveragesUrl(policyId: String) -> String {
        do {
            return try getBaseUrl() + String(format: WebServicesUrl.GET_COVERAGES, policyId)
        } catch let error {
            BSANLogger.i("WebServicesUrlProviderImpl", "FAILURE : \(#function) - \(error.localizedDescription)")
            return ""
        }
    }
    
    public func setUrlsForMulMov(_ urls: [String]) {
        self.urlsForMulMov = urls
    }
    
    public func setShouldUsePass2Urls(_ shouldUse: Bool) {
        shouldUsePass2Urls = shouldUse
    }
    
    public func isMulMovActivate(_ url: String) -> Bool {
        return self.urlsForMulMov.first { url.contains($0) } != nil
    }
}
