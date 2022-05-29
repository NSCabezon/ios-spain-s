import Foundation

struct InsuranceWebviewParameters: ProductWebviewParameters {
    var stockCode: String? {
        return nil
    }
    
    var identificationNumber: String? {
        return nil
    }
    
    var fundName: String? {
        return nil
    }
    var portfolioId: String? {
        return nil
    }
    
    let contractId: String?
    
    let family: String?
}
