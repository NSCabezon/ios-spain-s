//

import Foundation

public struct BizumMultimediaReceiverInputDTO: Codable {
    public let receiverUserId: String
    public let operationId: String

    public init(receiverUserId: String, operationId: String) {
        self.receiverUserId = receiverUserId
        self.operationId = operationId
    }
}

public struct BizumSendImageTextMultiInputDTO: Codable {
    let checkPayment: BizumCheckPaymentDTO
    let validateMoneyTransferMultiDTO: BizumValidateMoneyTransferMultiDTO
    let operationReceiverList: [BizumMultimediaReceiverInputDTO]
    let image: String?
    let imageFormat: BizumAttachmentImageType?
    let text: String?
}
