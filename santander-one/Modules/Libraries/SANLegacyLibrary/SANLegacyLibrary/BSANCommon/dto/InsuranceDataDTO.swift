
import SwiftyJSON

public struct InsuranceDataDTO: Codable, RestParser {
    
    /**
     * Número de Poliza
     */
    public let policyId: String?

    /**
     * Terceros
     */
    public let thirdPartyInd: String?

    /**
     * Family ID
     */
    public let familyId: String?

    /**
     * Family Description
     */
    public let familyDescription: String?
    public let factoryName: String?
    public let productName: String?
    public let customerId: String?
    public let policyStatus: String?
    public let cancelationReason: String?
    public let requestDate: String?
    public let factoryPolicyNumber: String?
    public let effectiveDate: String?
    public let dueDate: String?
    public let amendmentDate: String?
    public let emissionDate: String?
    public let cancelationDate: String?
    public let renewalDate: String?
    public let initialFee: AmountDTO?
    public let payMethodDescription: String?
    public let lastReceiptAmount: AmountDTO?
    public let totalAmount: AmountDTO?
    public let marketValueAmount: AmountDTO?
    public let periodicRemittance: AmountDTO?
    public let remittanceNumber: String?
    public let accountId: String?
    public let installmentAccountId: String?
    public let insuredAmount: AmountDTO?
    public let propertyType: String?
    public let propertyUse: String?
    public let address: String?
    public let town: String?
    public let buildingsAmount: AmountDTO?
    public let contentsAmount: AmountDTO?
    public let specialObjectsAmount: AmountDTO?
    public let healthCardNumber: String?
    
    public init(json : JSON) {
    
        self.policyId = json["policyId"].string
        self.thirdPartyInd = json["thirdPartyInd"].string
        self.familyId = json["familyId"].string
        self.familyDescription = json["familyDescription"].string
        self.factoryName = json["factoryName"].string
        self.productName = json["productName"].string
        self.customerId = json["customerId"].string
        self.policyStatus = json["policyStatus"].string
        self.cancelationReason = json["cancelationReason"].string
        self.requestDate = json["requestDate"].string
        self.factoryPolicyNumber = json["factoryPolicyNumber"].string
        self.effectiveDate = json["effectiveDate"].string
        self.dueDate = json["dueDate"].string
        self.amendmentDate = json["amendmentDate"].string
        self.emissionDate = json["emissionDate"].string
        self.cancelationDate = json["cancelationDate"].string
        self.renewalDate = json["renewalDate"].string
        let initialFeeJSON = json["initialFee"]
        self.initialFee = initialFeeJSON != JSON.null ? AmountDTO(json: initialFeeJSON) : nil
        self.payMethodDescription = json["payMethodDescription"].string
        let lastReceiptJSON = json["lastReceiptAmount"]
        self.lastReceiptAmount = lastReceiptJSON != JSON.null ? AmountDTO(json: lastReceiptJSON) : nil
        let totalAmountJSON = json["totalAmount"]
        self.totalAmount = totalAmountJSON != JSON.null ? AmountDTO(json: totalAmountJSON) : nil
        let marketValueAmountJSON = json["marketValueAmount"]
        self.marketValueAmount = marketValueAmountJSON != JSON.null ? AmountDTO(json: marketValueAmountJSON) : nil
        let periodicRemittanceJSON = json["periodicRemittance"]
        self.periodicRemittance = periodicRemittanceJSON != JSON.null ? AmountDTO(json: periodicRemittanceJSON) : nil
        self.remittanceNumber = json["remittanceNumber"].stringValue
        self.accountId = json["accountId"].string
        self.installmentAccountId = json["installmentAccountId"].string
        let insuredAmountJSON = json["insuredAmount"]
        self.insuredAmount = insuredAmountJSON != JSON.null ? AmountDTO(json: insuredAmountJSON) : nil
        self.propertyType = json["propertyType"].string
        self.propertyUse = json["propertyUse"].string
        self.address = json["address"].string
        self.town = json["town"].string
        let buildingsAmountJSON = json["buildingsAmount"]
        self.buildingsAmount = buildingsAmountJSON != JSON.null ? AmountDTO(json: buildingsAmountJSON) : nil
        let contentsAmountJSON = json["contentsAmount"]
        self.contentsAmount = contentsAmountJSON != JSON.null ? AmountDTO(json: contentsAmountJSON) : nil
        let specialObjectsAmountJSON = json["specialObjectsAmount"]
        self.specialObjectsAmount = specialObjectsAmountJSON != JSON.null ? AmountDTO(json: specialObjectsAmountJSON) : nil
        self.healthCardNumber = "\(json["healthCardNumber"].numberValue)"
    }
}
