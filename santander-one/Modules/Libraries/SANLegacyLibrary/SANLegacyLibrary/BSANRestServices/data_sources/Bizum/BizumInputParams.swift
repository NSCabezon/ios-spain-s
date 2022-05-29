import Foundation

public struct BizumGetContactsInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let contactList: [String]
    
    public init(checkPayment: BizumCheckPaymentDTO,
                contactList: [String]) {
        self.checkPayment = checkPayment
        self.contactList = contactList
    }
}

public struct BizumOperationsInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let page: Int
    public let dateFrom: Date
    public let dateTo: Date
    public let orderBy: String?
    public let orderType: String?
    
    public init(checkPayment: BizumCheckPaymentDTO,
                page: Int,
                dateFrom: Date,
                dateTo: Date,
                orderBy: String?,
                orderType: String?) {
        self.checkPayment = checkPayment
        self.page = page
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.orderBy = orderBy
        self.orderType = orderType
    }
}

public struct BizumValidateMoneyTransferInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let document: BizumRedsysDocumentDTO
    public let dateTime: Date
    public let concept: String
    public let amount: String
    public let receiverUserId: String
    public let account: AccountDTO?
    
    public init(checkPayment: BizumCheckPaymentDTO,
                document: BizumRedsysDocumentDTO,
                dateTime: Date,
                concept: String,
                amount: String,
                receiverUserId: String,
                account: AccountDTO?) {
        self.checkPayment = checkPayment
        self.document = document
        self.dateTime = dateTime
        self.concept = concept
        self.amount = amount
        self.receiverUserId = receiverUserId
        self.account = account
    }
}

public struct BizumValidateMoneyTransferOTPInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let signatureWithTokenDTO: SignatureWithTokenDTO
    public let amount: String
    public let footPrint: String?
    public let deviceMagicPhrase: String?
    public let numberOfRecipients: Int
    public let operation: String
    public let account: AccountDTO?
    
    public init(checkPayment: BizumCheckPaymentDTO, signatureWithTokenDTO: SignatureWithTokenDTO, amount: String, numberOfRecipients: Int, operation: String, account: AccountDTO?, footPrint: String?, deviceMagicPhrase: String?) {
        self.checkPayment = checkPayment
        self.signatureWithTokenDTO = signatureWithTokenDTO
        self.amount = amount
        self.numberOfRecipients = numberOfRecipients
        self.operation = operation
        self.account = account
        self.footPrint = footPrint
        self.deviceMagicPhrase = deviceMagicPhrase
    }
    
    @available(*, deprecated, message: "Use init(checkPayment: BizumCheckPaymentDTO, signatureWithTokenDTO: SignatureWithTokenDTO, amount: String)")
    public init(checkPayment: BizumCheckPaymentDTO, signatureWithTokenDTO: SignatureWithTokenDTO, amount: Decimal, numberOfRecipients: Int, operation: String, footPrint: String?, deviceMagicPhrase: String?) {
        self.checkPayment = checkPayment
        self.signatureWithTokenDTO = signatureWithTokenDTO
        self.amount = NSDecimalNumber(decimal: amount).stringValue
        self.numberOfRecipients = numberOfRecipients
        self.operation = operation
        self.account = nil
        self.footPrint = footPrint
        self.deviceMagicPhrase = deviceMagicPhrase
     }
}

public struct BizumSignRefundMoneyInputParams {
    public let iban: IBANDTO
    public let signatureWithTokenDTO: SignatureWithTokenDTO
    public let amount: AmountDTO
    
    public init(iban: IBANDTO,
                signatureWithTokenDTO: SignatureWithTokenDTO,
                amount: AmountDTO) {
        self.iban = iban
        self.signatureWithTokenDTO = signatureWithTokenDTO
        self.amount = amount
    }
}

public struct BizumAcceptRequestMoneyTransferOTPInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let otpValidationDTO: OTPValidationDTO
    public let document: BizumRedsysDocumentDTO
    public let otpCode: String
    public let operationId: String
    public let dateTime: Date
    public let concept: String
    public let amount: String
    public let receiverUserId: String
    public let magicPhrasePush: String?

    public init(checkPayment: BizumCheckPaymentDTO, otpValidationDTO: OTPValidationDTO, document: BizumRedsysDocumentDTO, otpCode: String, operationId: String, dateTime: Date, concept: String, amount: String, receiverUserId: String, magicPhrasePush: String?) {
        self.checkPayment = checkPayment
        self.otpValidationDTO = otpValidationDTO
        self.document = document
        self.otpCode = otpCode
        self.operationId = operationId
        self.dateTime = dateTime
        self.concept = concept
        self.amount = amount
        self.receiverUserId = receiverUserId
        self.magicPhrasePush = magicPhrasePush
    }
}

public struct BizumMoneyTransferOTPInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let otpValidationDTO: OTPValidationDTO
    public let document: BizumRedsysDocumentDTO
    public let otpCode: String
    public let validateMoneyTransferDTO: BizumValidateMoneyTransferDTO
    public let dateTime: Date
    public let concept: String
    public let amount: String
    public let receiverUserId: String
    public let account: AccountDTO?
    public let magicPhrasePush: String?

    public init(checkPayment: BizumCheckPaymentDTO, otpValidationDTO: OTPValidationDTO, document: BizumRedsysDocumentDTO, otpCode: String, validateMoneyTransferDTO: BizumValidateMoneyTransferDTO, dateTime: Date, concept: String, amount: String, receiverUserId: String, account: AccountDTO?, magicPhrasePush: String?) {
        self.checkPayment = checkPayment
        self.otpValidationDTO = otpValidationDTO
        self.document = document
        self.otpCode = otpCode
        self.validateMoneyTransferDTO = validateMoneyTransferDTO
        self.dateTime = dateTime
        self.concept = concept
        self.amount = amount
        self.receiverUserId = receiverUserId
        self.account = account
        self.magicPhrasePush = magicPhrasePush
    }
}

public struct BizumValidateMoneyTransferMultiInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let document: BizumRedsysDocumentDTO
    public let dateTime: Date
    public let concept: String
    public let amount: String
    public let receiverUserIds: [String]
    public let account: AccountDTO?
    
    public init(checkPayment: BizumCheckPaymentDTO,
                document: BizumRedsysDocumentDTO,
                dateTime: Date,
                concept: String,
                amount: String,
                receiverUserIds: [String],
                account: AccountDTO?) {
        self.checkPayment = checkPayment
        self.document = document
        self.dateTime = dateTime
        self.concept = concept
        self.amount = amount
        self.receiverUserIds = receiverUserIds
        self.account = account
    }
}

public struct BizumMoneyTransferOTPMultiInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let otpValidationDTO: OTPValidationDTO
    public let document: BizumRedsysDocumentDTO
    public let otpCode: String
    public let validateMoneyTransferMultiDTO: BizumValidateMoneyTransferMultiDTO
    public let dateTime: Date
    public let concept: String
    public let amount: String
    public let account: AccountDTO?
    public let tokenPush: String?
    
    public init(checkPayment: BizumCheckPaymentDTO,
                otpValidationDTO: OTPValidationDTO,
                document: BizumRedsysDocumentDTO,
                otpCode: String,
                validateMoneyTransferMultiDTO: BizumValidateMoneyTransferMultiDTO,
                dateTime: Date,
                concept: String,
                amount: String,
                account: AccountDTO?,
                tokenPush: String?) {
        self.checkPayment = checkPayment
        self.otpValidationDTO = otpValidationDTO
        self.document = document
        self.otpCode = otpCode
        self.validateMoneyTransferMultiDTO = validateMoneyTransferMultiDTO
        self.dateTime = dateTime
        self.concept = concept
        self.amount = amount
        self.account = account
        self.tokenPush = tokenPush
    }
}

public struct BizymMultimediaUsersInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let contactList: [String]
    
    public init(checkPayment: BizumCheckPaymentDTO,
                contactList: [String]) {
        self.checkPayment = checkPayment
        self.contactList = contactList
    }
}

public struct BizumMultimediaContentInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let operationId: String
    
    public init(checkPayment: BizumCheckPaymentDTO,
                operationId: String) {
        self.checkPayment = checkPayment
        self.operationId = operationId
    }
}

public struct BizumAcceptRequestSendMultimediaInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let operationId: String
    public let receiverUserId: String
    public let image: String?
    public let imageFormat: BizumAttachmentImageType?
    public let text: String?
    
    public init(checkPayment: BizumCheckPaymentDTO,
                operationId: String,
                receiverUserId: String,
                image: String?,
                imageFormat: BizumAttachmentImageType?,
                text: String?) {
        self.checkPayment = checkPayment
        self.operationId = operationId
        self.receiverUserId = receiverUserId
        self.image = image
        self.imageFormat = imageFormat
        self.text = text
    }
}

public enum BizumSendMultimediaOperationTypeDTO: String {
    case send = "C2CED"
    case acceptMoneyRequest = "C2CASD"
    case refundMoney = "C2CDD"
    case requestMoney = "C2CSD"
}

public struct BizumSendMultimediaInputParams {
    
    public let checkPayment: BizumCheckPaymentDTO
    public let operationId: String
    public let receiverUserId: String
    public let image: String?
    public let imageFormat: BizumAttachmentImageType?
    public let text: String?
    public let operationType: BizumSendMultimediaOperationTypeDTO
    
    public init(checkPayment: BizumCheckPaymentDTO,
                operationId: String,
                receiverUserId: String,
                image: String?,
                imageFormat: BizumAttachmentImageType?,
                text: String?,
                operationType: BizumSendMultimediaOperationTypeDTO) {
        self.checkPayment = checkPayment
        self.operationId = operationId
        self.receiverUserId = receiverUserId
        self.image = image
        self.imageFormat = imageFormat
        self.text = text
        self.operationType = operationType
    }
    
    @available(*, deprecated, message: "Use the other constructor")
    public init(checkPayment: BizumCheckPaymentDTO,
                validateTransferDTO: BizumValidateMoneyTransferDTO,
                receiverUserId: String,
                image: String?,
                imageFormat: BizumAttachmentImageType?,
                text: String?) {
        self.checkPayment = checkPayment
        self.operationId = validateTransferDTO.operationId
        self.receiverUserId = receiverUserId
        self.image = image
        self.imageFormat = imageFormat
        self.text = text
        self.operationType = .send
    }
}

public struct BizumSendImageTextMultiInputParams {
    public let emmiterUserId: String
    public let multiOperationId: String
    public let operationReceiverList: [BizumMultimediaReceiverInputParam]
    public let image: String?
    public let imageFormat: BizumAttachmentImageType?
    public let text: String?
    public let operationType: BizumSendMultimediaOperationTypeDTO
    
    public init(emmiterUserId: String,
                multiOperationId: String,
                operationReceiverList: [BizumMultimediaReceiverInputParam],
                image: String?,
                imageFormat: BizumAttachmentImageType?,
                text: String?,
                operationType: BizumSendMultimediaOperationTypeDTO) {
        self.emmiterUserId = emmiterUserId
        self.multiOperationId = multiOperationId
        self.operationReceiverList = operationReceiverList
        self.image = image
        self.imageFormat = imageFormat
        self.text = text
        self.operationType = operationType
    }
}

public struct BizumMultimediaReceiverInputParam {
    public let receiverUserId: String
    public let operationId: String
    
    public init(receiverUserId: String,
                operationId: String) {
        self.receiverUserId = receiverUserId
        self.operationId = operationId
    }
}

public struct BizumInviteNoClientOTPInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let otpValidationDTO: OTPValidationDTO
    public let otpCode: String
    public let validateMoneyTransferDTO: BizumValidateMoneyTransferDTO
    public let amount: String
    
    @available(*, deprecated, message: "Use init(checkPayment: BizumCheckPaymentDTO, otpValidationDTO: OTPValidationDTO, otpCode: String, validateMoneyTransferDTO: BizumValidateMoneyTransferDTO, amount: Decimal)")
    public init(validateMoneyTransferDTO: BizumValidateMoneyTransferDTO) {
        self.checkPayment = BizumCheckPaymentDTO(
            phone: "",
            contractIdentifier: BizumCheckPaymentContractDTO(center: CentroDTO(), subGroup: "", contractNumber: ""),
            initialDate: Date(),
            endDate: Date(),
            back: nil,
            message: nil,
            ibanCode: BizumCheckPaymentIBANDTO(country: "", controlDigit: "", codbban: ""),
            offset: nil,
            offsetState: nil, indMigrad: "",
            xpan: ""
        )
        self.otpValidationDTO = OTPValidationDTO()
        self.otpCode = ""
        self.validateMoneyTransferDTO = validateMoneyTransferDTO
        self.amount = "0.0"
    }
    
    public init(checkPayment: BizumCheckPaymentDTO,
                otpValidationDTO: OTPValidationDTO,
                otpCode: String,
                validateMoneyTransferDTO: BizumValidateMoneyTransferDTO,
                amount: String) {
        self.checkPayment = checkPayment
        self.otpValidationDTO = otpValidationDTO
        self.otpCode = otpCode
        self.validateMoneyTransferDTO = validateMoneyTransferDTO
        self.amount = amount
    }
}

public struct BizumInviteNoClientInputParams {
    public let validateMoneyRequestDTO: BizumValidateMoneyRequestDTO
    
    public init(validateMoneyRequestDTO: BizumValidateMoneyRequestDTO) {
        self.validateMoneyRequestDTO = validateMoneyRequestDTO
    }
}

public struct BizumOperationListMultipleInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let formDate: Date
    public let toDate: Date
    public let page: Int
    public let elements: Int
    
    public init(checkPayment: BizumCheckPaymentDTO,
                formDate: Date,
                toDate: Date,
                page: Int,
                elements: Int) {
        self.checkPayment = checkPayment
        self.formDate = formDate
        self.toDate = toDate
        self.page = page
        self.elements = elements
    }
}

public struct BizumOperationMultipleListDetailInputParams {
    public let checkPayment: BizumCheckPaymentDTO
    public let operation: BizumOperationMultiDTO
    
    public init(checkPayment: BizumCheckPaymentDTO,
                operation: BizumOperationMultiDTO) {
        self.checkPayment = checkPayment
        self.operation = operation
    }
}

public struct BizumValidateMoneyRequestInputParams: Codable {
    public let checkPayment: BizumCheckPaymentDTO
    public let document: BizumRedsysDocumentDTO
    public let dateTime: Date
    public let concept: String
    public let amount: String
    public let receiverUserId: String
    
    public init(checkPayment: BizumCheckPaymentDTO,
                document: BizumRedsysDocumentDTO,
                dateTime: Date,
                concept: String,
                amount: String,
                receiverUserId: String) {
        self.checkPayment = checkPayment
        self.document = document
        self.dateTime = dateTime
        self.concept = concept
        self.amount = amount
        self.receiverUserId = receiverUserId
    }
}

public struct BizumMoneyRequestInputParams: Codable {
    public let checkPayment: BizumCheckPaymentDTO
    public let document: BizumRedsysDocumentDTO
    public let operationId: String
    public let dateTime: Date
    public let concept: String
    public let amount: String
    public let receiverUserId: String
    
    public init(checkPayment: BizumCheckPaymentDTO,
                document: BizumRedsysDocumentDTO,
                operationId: String,
                dateTime: Date,
                concept: String,
                amount: String,
                receiverUserId: String) {
        self.checkPayment = checkPayment
        self.document = document
        self.operationId = operationId
        self.dateTime = dateTime
        self.concept = concept
        self.amount = amount
        self.receiverUserId = receiverUserId
    }
}

public struct BizumValidateMoneyRequestMultiInputParams: Codable {
    public let checkPayment: BizumCheckPaymentDTO
    public let document: BizumRedsysDocumentDTO
    public let dateTime: Date
    public let concept: String
    public let amount: String
    public let receiverUserIds: [String]
    
    public init(checkPayment: BizumCheckPaymentDTO,
                document: BizumRedsysDocumentDTO,
                dateTime: Date,
                concept: String,
                amount: String,
                receiverUserIds: [String]) {
        self.checkPayment = checkPayment
        self.document = document
        self.dateTime = dateTime
        self.concept = concept
        self.amount = amount
        self.receiverUserIds = receiverUserIds
    }
}

public struct BizumMoneyRequestMultiInputParams: Codable {
    public let checkPayment: BizumCheckPaymentDTO
    public let document: BizumRedsysDocumentDTO
    public let dateTime: Date
    public let concept: String
    public let amount: String
    public let operationId: String
    public let actions: [BizumMoneyRequestMultiActionInputParam]
    
    public init(checkPayment: BizumCheckPaymentDTO,
                document: BizumRedsysDocumentDTO,
                dateTime: Date,
                concept: String,
                amount: String,
                operationId: String,
                actions: [BizumMoneyRequestMultiActionInputParam]) {
        self.checkPayment = checkPayment
        self.document = document
        self.dateTime = dateTime
        self.concept = concept
        self.amount = amount
        self.operationId = operationId
        self.actions = actions
    }
}

public struct BizumMoneyRequestMultiActionInputParam: Codable {
    public let operationId: String
    public let receiverUserId: String
    public let action: String
    
    public init(operationId: String,
                receiverUserId: String,
                action: String) {
        self.operationId = operationId
        self.receiverUserId = receiverUserId
        self.action = action
    }
}

public struct BizumCancelNotRegisterInputParam: Codable {
    public let checkPayment: BizumCheckPaymentDTO
    public let document: BizumRedsysDocumentDTO
    public let operation: BizumOperationDTO
    public let dateTime: Date
    
    public init(checkPayment: BizumCheckPaymentDTO,
                document: BizumRedsysDocumentDTO,
                operation: BizumOperationDTO,
                dateTime: Date) {
        self.checkPayment = checkPayment
        self.document = document
        self.operation = operation
        self.dateTime = dateTime
    }
}

public struct BizumRefundMoneyRequestInputParams: Codable {
    public let checkPayment: BizumCheckPaymentDTO
    public let operationId: String
    public let otpValidationDTO: OTPValidationDTO?
    public let document: BizumRedsysDocumentDTO
    public let otpCode: String
    public let dateTime: Date
    public let amount: Decimal
    public let concept: String
    public let receiverUserId: String
    public let transactionId: String
    
    public init(checkPayment: BizumCheckPaymentDTO,
                operationId: String,
                transactionId: String,
                otpValidationDTO: OTPValidationDTO?,
                otpCode: String,
                dateTime: Date,
                concept: String,
                amount: Decimal,
                document: BizumRedsysDocumentDTO,
                receiverId: String) {
        self.checkPayment = checkPayment
        self.operationId = operationId
        self.otpValidationDTO = otpValidationDTO
        self.document = document
        self.otpCode = otpCode
        self.dateTime = dateTime
        self.amount = amount
        self.concept = concept
        self.receiverUserId = receiverId
        self.transactionId = transactionId
    }
}

public struct BizumGetOrganizationsInputParams: Codable {
    public let pageNumber: Int
    
    public init(pageNumber: Int) {
        self.pageNumber = pageNumber
    }
}

public struct BizumGetRedsysDocumentInputParams {
    public let phoneNumber: String
    
    public init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
}
