import Foundation

public class UserDataOld: NSObject, NSCoding {
    public let bankCode: String?                        // empresa
    public let personType: String?                      // cliente.TIPO_DE_PERSONA
    public let personCode: String?                      // cliente.CODIGO_DE_PERSONA
    public let canalMarco: String?                      // canalMarco
    public let bankCodeMultichannelContract: String?    // contratoMulticanal.CENTRO.EMPRESA
    public let branchCodeMultichannelContract: String?  // contratoMulticanal.CENTRO.CENTRO
    public let productMultichannelContract: String?     // contratoMulticanal.PRODUCTO
    public let multichannelContractNumber: String?      // contratoMulticanal.NUMERO_DE_CONTRATO
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(bankCode, forKey: "bankCode")
        aCoder.encode(personType, forKey: "personType")
        aCoder.encode(personCode, forKey: "personCode")
        aCoder.encode(canalMarco, forKey: "canalMarco")
        aCoder.encode(bankCodeMultichannelContract, forKey: "bankCodeMultichannelContract")
        aCoder.encode(branchCodeMultichannelContract, forKey: "branchCodeMultichannelContract")
        aCoder.encode(productMultichannelContract, forKey: "productMultichannelContract")
        aCoder.encode(multichannelContractNumber, forKey: "multichannelContractNumber")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.bankCode = aDecoder.decodeObject(forKey: "bankCode") as? String
        self.personType = aDecoder.decodeObject(forKey: "personType") as? String
        self.personCode = aDecoder.decodeObject(forKey: "personCode") as? String
        self.canalMarco = aDecoder.decodeObject(forKey: "canalMarco") as? String
        self.bankCodeMultichannelContract = aDecoder.decodeObject(forKey: "bankCodeMultichannelContract") as? String
        self.branchCodeMultichannelContract = aDecoder.decodeObject(forKey: "branchCodeMultichannelContract") as? String
        self.productMultichannelContract = aDecoder.decodeObject(forKey: "productMultichannelContract") as? String
        self.multichannelContractNumber = aDecoder.decodeObject(forKey: "multichannelContractNumber") as? String
    }
}
