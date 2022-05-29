import CoreFoundationLib

public class CipherKeys{
    
    public var userDataDTO : UserDataDTO
    
    public init(userDataDTO: UserDataDTO) {
        self.userDataDTO = userDataDTO
    }
    
    public func getCipherKeys(keyNoCipher : String) -> String?{
        
        guard let contract = userDataDTO.contract else{
            return nil
        }
        
        var cmc = ""
        if let bankCode = contract.bankCode,
            let branchCode = contract.branchCode,
            let product = contract.product,
            let contractNumber = contract.contractNumber{
            
            cmc = "\(bankCode)\(branchCode)\(product)\(contractNumber)"
        }
        
        let canalMarco = userDataDTO.channelFrame ?? ""
        let tipoPersona = userDataDTO.clientPersonType ?? ""
        let codigoPersona = userDataDTO.clientPersonCode ?? ""
        var claveCifrado = cmc + canalMarco + tipoPersona + codigoPersona
        
        let initialLenght = claveCifrado.count
        if claveCifrado.count < 32{
            for _ in initialLenght ... 31{
                claveCifrado += "0"
            }
        }

        do {
            let testCipher = try DataCipher.encryptDESde(keyNoCipher, claveCifrado.substring(0, 32) ?? "")
            return testCipher
        }
        catch _ as NSError{
            return nil
        }
    }
    
}
