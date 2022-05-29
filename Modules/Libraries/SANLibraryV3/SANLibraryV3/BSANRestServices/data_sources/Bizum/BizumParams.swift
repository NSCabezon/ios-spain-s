import Foundation

struct BizumGetContactsParams: Codable {
    let cmc: String
    let language: String
    let phoneNumber: String
    let contactList: [String]
}

struct BizumValidateMoneyTransferParams: Codable {
    let operationId: String
    let transactionId: String
    let state: String?
    let cmc: String
    let language: String
    let dateTime: String
    let concept: String
    let amount: String
    let emitterLanguage: String
    let emitterAlias: String
    let emitterName: String
    let emitterUserId: String
    let receiverUserId: String
    let emitterVirtualElement: String
    let emitterDocumentType: String
    let emitterDocumentCode: String
    let emitterIban: String
    let emitterIbanCurrency: String
}

struct BizumValidateMoneyTransferMultiParams: Codable {
    let cmc: String
    let language: String
    let dateTime: String
    let concept: String
    let amount: String
    let emitterLanguage: String
    let emitterAlias: String
    let emitterName: String
    let emitterUserId: String
    let receiverUserIds: [String]
    let emitterVirtualElement: String
    let emitterDocumentType: String
    let emitterDocumentCode: String
    let emitterIban: String
    let emitterIbanCurrency: String
}

struct BizumValidateMoneyTransferOTPParams: Codable {
    let cmc: String
    let language: String
    let signPositions: [String: String]
    let securityToken: String
    let emitterIban: String
    let emitterIbanCurrency: String
    let amount: String
    let numberOfRecipients: Int
    let operation: String
    let footPrint: String?
    let deviceMagicPhrase: String?
    
    enum CodingKeys: String, CodingKey {
        case cmc
        case language
        case signPositions
        case securityToken
        case emitterIban
        case emitterIbanCurrency
        case amount
        case numberOfRecipients
        case operation
        case footPrint
        case deviceMagicPhrase = "deviceToken"
    }
}

struct BizumMoneyTransferOTPParams: Codable {
    let operation: String
    let securityToken: String
    let otpTicket: String
    let otpCode: String
    let operationId: String
    let transactionId: String
    let state: String
    let cmc: String
    let language: String
    let dateTime: String
    let concept: String
    let amount: String
    let emitterLanguage: String
    let emitterAlias: String
    let emitterName: String
    let emitterUserId: String
    let receiverUserId: String
    let emitterVirtualElement: String
    let emitterDocumentType: String
    let emitterDocumentCode: String
    let emitterIban: String
    let emitterIbanCurrency: String
    let tokenPush: String?
}

struct BizumMoneyTransferMultiParams: Codable {
    let securityToken: String
    let otpTicket: String
    let otpCode: String
    let operationId: String
    let cmc: String
    let language: String
    let dateTime: String
    let concept: String
    let amount: String
    let emitterLanguage: String
    let emitterAlias: String
    let emitterName: String
    let emitterUserId: String
    let emitterVirtualElement: String
    let emitterDocumentType: String
    let emitterDocumentCode: String
    let emitterIban: String
    let emitterIbanCurrency: String
    let actions: [BizumReceiverOperationParams]
    let tokenPush: String?
}

struct BizumReceiverOperationParams: Codable {
    let operationId: String
    let receiverUserId: String
    let action: String
}

struct SignPositionParams: Codable {
    let cmc: String
    let language: String
    let application: String
}

struct BizumInviteNoClientOTPParams: Codable {
    let cmc: String
    let language: String
    let operationId: String
    let amount: String
    let currency: String
    let token: String
    let otpTicket: String
    let otpCode: String
}

struct BizumInviteNoClientParams: Codable {
    let cmc: String
    let language: String
    let operationId: String
}

struct BizumSendImageTextParams: Codable {
    let cmc: String
    let language: String
    let emitterUserId: String
    let petitionType: String
    let operationId: String
    let receiverUserId: String
    let image: String?
    let imageFormat: String?
    let text: String?
}

struct BizumMultimediaReceiverParam: Codable {
    let receiverUserId: String
    let operationId: String
}

struct BizumSendImageTextMultiParams: Codable {
    let cmc: String
    let language: String
    let emitterUserId: String
    let petitionType: String
    let multiOperationId: String
    let operationReceiverList: [BizumMultimediaReceiverParam]
    let image: String?
    let imageFormat: String?
    let text: String?
}

struct EmptyParams: Codable { }

struct BizumOperationsParams: Codable {
    let cmc: String
    let language: String
    let emitterUserId: String
    let fromTimestamp: String
    let toTimestamp: String
    let elements: Int
    let pageNumber: Int
    let orderBy: String
    let orderType: String
    let requestFields: [String]
    let conditions: [String]
    
    var uniqueKey: String {
        let requestFieldsUniqueKey = self.requestFields.reduce(into: "") { $0 = $0 + $1 }
        let conditionsUniqueKey = self.conditions.reduce(into: "") { $0 = $0 + $1 }
        let pageNumberKey = "\(self.pageNumber)"
        return self.cmc + self.language + self.emitterUserId + self.fromTimestamp + self.toTimestamp + pageNumberKey + self.orderBy + self.orderType + requestFieldsUniqueKey + conditionsUniqueKey
    }
}

struct BizumOperationListMultiple: Codable {
    let cmc: String
    let language: String
    let emitterUserId: String
    let fromTimestamp: String
    let toTimestamp: String
    let elements: Int
    let pageNumber: Int
    
    var uniqueKey: String {
        let pageNumberKey = "\(self.pageNumber)"
        let elementsKey = "\(self.elements)"
        return self.cmc + self.language + self.emitterUserId + self.fromTimestamp + self.toTimestamp + pageNumberKey + elementsKey
    }
}

struct BizumOperationMultipleDetail: Codable {
    let cmc: String
    let language: String
    let emitterUserId: String
    let operationId: String
}

struct BizumValidateMoneyRequestParams: Codable {
    let cmc: String
    let language: String
    let dateTime: String
    let concept: String
    let amount: String
    let emitterLanguage: String
    let emitterAlias: String
    let emitterName: String
    let emitterUserId: String
    let receiverUserId: String
    let emitterVirtualElement: String
    let emitterDocumentType: String
    let emitterDocumentCode: String
    let emitterIban: String
    let emitterIbanCurrency: String
}

struct BizumMoneyRequestParams: Codable {
    let operationId: String
    let transactionId: String
    let state: String
    let cmc: String
    let language: String
    let dateTime: String
    let concept: String
    let amount: String
    let emitterLanguage: String
    let emitterAlias: String
    let emitterName: String
    let emitterUserId: String
    let receiverUserId: String
    let emitterVirtualElement: String
    let emitterDocumentType: String
    let emitterDocumentCode: String
    let emitterIban: String
    let emitterIbanCurrency: String
}

struct BizumValidateMoneyRequestMultiParams: Codable {
    let cmc: String
    let language: String
    let dateTime: String
    let concept: String
    let amount: String
    let emitterLanguage: String
    let emitterAlias: String
    let emitterName: String
    let emitterVirtualElement: String
    let emitterDocumentType: String
    let emitterDocumentCode: String
    let emitterIban: String
    let emitterIbanCurrency: String
    let emitterUserId: String
    let receiverUserIds: [String]
}

struct BizumMoneyRequestMultiParams: Codable {
    let cmc: String
    let language: String
    let dateTime: String
    let concept: String
    let amount: String
    let emitterLanguage: String
    let emitterAlias: String
    let emitterName: String
    let emitterVirtualElement: String
    let emitterDocumentType: String
    let emitterDocumentCode: String
    let emitterIban: String
    let emitterIbanCurrency: String
    let emitterUserId: String
    let operationId: String
    let actions: [BizumMoneyRequestMultiActionParam]
}

struct BizumMoneyRequestMultiActionParam: Codable {
    let operationId: String
    let receiverUserId: String
    let action: String
}

struct BizumCancelNotRegisterParam: Codable {
    let operationId: String
    let transactionId: String = ""
    let state: String
    let cmc: String
    let language: String = " pi-PI"
    let dateTime: String
    let concept: String
    let amount: String
    let emitterLanguage: String = "spa"
    let emitterAlias: String
    let emitterName: String
    let emitterUserId: String
    let receiverUserId: String
    let emitterVirtualElement: String
    let emitterDocumentType: String
    let emitterDocumentCode: String
    let emitterIban: String
    let emitterIbanCurrency: String
}

struct BizumRefundMoneyRequestParams: Codable {
    let securityToken: String
    let otpTicket: String
    let otpCode: String
    let operationId: String
    let transactionId: String
    let state: String
    let cmc: String
    let language: String
    let dateTime: String
    let concept: String
    let amount: String
    let emitterLanguage: String
    let emitterAlias: String
    let emitterName: String
    let emitterUserId: String
    let emitterVirtualElement: String
    let emitterDocumentType: String
    let emitterDocumentCode: String
    let emitterIban: String
    let emitterIbanCurrency: String
    let receiverUserId: String
}

struct BizumGetOrganizationsParams: Codable {
    let language: String
    let cmc: String
    let userType: String
    let mode: String
    let elements: Int
    let pageNumber: Int
    
    var uniqueKey: String {
        let pageNumberKey = "\(self.pageNumber)"
        let elements = "\(self.elements)"
        return self.cmc + self.language + self.userType + self.mode + pageNumberKey + elements
    }
}

struct BizumGetRedsysDocumentParams: Codable {
    let cmc: String
    let language: String
    let phoneNumber: String
}
