import SANLegacyLibrary

class ContractDO: GenericProduct {
    private(set) var contractDTO: ContractDTO?
    
    override init() {
        super.init()
    }
    
    init(contractDTO: ContractDTO) {
        self.contractDTO = contractDTO
        super.init()
    }
    
    var contractPK: String? {
        return contractDTO?.contratoPK
    }
    
    var contractNumber: String? {
        return contractDTO?.contractNumber
    }
    
    var contractShort: String {
        guard let contractNumber = contractDTO?.contractNumber else { return "****" }
        return "***" + (contractNumber.substring(contractNumber.count - 4) ?? "*")
    }
    
    override func getAlias() -> String? {
        return nil
    }
    
    override func getAliasAndInfo(withCustomAlias alias: String?) -> String {
        return transformToAliasAndInfo(alias: alias ?? getAliasCamelCase()) + " | " + contractShort
    }
}
