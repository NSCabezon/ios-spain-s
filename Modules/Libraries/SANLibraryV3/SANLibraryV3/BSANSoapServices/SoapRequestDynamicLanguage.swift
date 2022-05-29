protocol SoapRequestDynamicLanguage {
    var serviceName: String { get }
}

extension SoapRequestDynamicLanguage {
    
    var serviceLanguage: ServiceNameLanguage? {
        return BSANBaseManager.serviceNameLanguage
    }
    
    func serviceLanguage(_ otherLanguage: String) -> String {
        return serviceLanguage?.validLanguageForService(currentService: serviceName, originalLanguage: otherLanguage) ?? otherLanguage
    }
    
    func serviceLanguage(originalLanguage: String, dialectISO: String) -> String {
        guard let serviceLanguage: ServiceNameLanguage = serviceLanguage else {
            return originalLanguage
        }
        return serviceLanguage.validLanguageForService(currentService: serviceName, originalLanguage: originalLanguage, dialectISO: dialectISO)
    }
}
