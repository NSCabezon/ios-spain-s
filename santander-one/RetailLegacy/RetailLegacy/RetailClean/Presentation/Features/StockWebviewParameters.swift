struct StockWebviewParameters: ProductWebviewParameters {
    var contractId: String?
    var stockCode: String?
    var identificationNumber: String?
    
    var fundName: String? {
        return nil
    }
    var portfolioId: String? {
        return nil
    }
    
    var family: String? {
        return nil
    }
}
