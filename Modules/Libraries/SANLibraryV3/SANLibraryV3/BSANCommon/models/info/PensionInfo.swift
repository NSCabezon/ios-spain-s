public struct PensionInfo: Codable {
    public var pensionTransactionsDictionary: [String : PensionTransactionsListDTO] = [:]
    public var pensionDetailDictionary: [String : PensionDetailDTO] = [:]
    public var pensionContributionsDictionary: [String : PensionContributionsListDTO] = [:]

    public mutating func addPensionTransactions(pensionTransactionsListDTO: PensionTransactionsListDTO, contract: String) {
        var newStoredTransactions = [PensionTransactionDTO]()
        if let storedTransactions = pensionTransactionsDictionary[contract] {
            newStoredTransactions = storedTransactions.transactionDTOs
        }
        for trans in pensionTransactionsListDTO.transactionDTOs {
            if !newStoredTransactions.map({$0.transactionNumber}).contains(trans.transactionNumber) {
                newStoredTransactions.append(trans)
            }
        }
        pensionTransactionsDictionary[contract] = PensionTransactionsListDTO(transactionDTOs: newStoredTransactions, pagination: pensionTransactionsListDTO.pagination)
    }
    
    public mutating func addPensionContributions(pensionContributionsListDTO: PensionContributionsListDTO, contractId: String) {
        guard var pensionContributions = pensionContributionsListDTO.pensionContributions else {
            return
        }
        
        var storedPensionContributions = pensionContributionsDictionary[contractId]
        
        if let storedPensionContributions = storedPensionContributions,
            let storedContributionsList = storedPensionContributions.pensionContributions {
            pensionContributions += storedContributionsList
        }
        
        storedPensionContributions = PensionContributionsListDTO(pensionContributions: pensionContributions, pensionInfoOperationDTO: pensionContributionsListDTO.pensionInfoOperationDTO, pagination: pensionContributionsListDTO.pagination)
        pensionContributionsDictionary[contractId] = storedPensionContributions
        
    }
}
