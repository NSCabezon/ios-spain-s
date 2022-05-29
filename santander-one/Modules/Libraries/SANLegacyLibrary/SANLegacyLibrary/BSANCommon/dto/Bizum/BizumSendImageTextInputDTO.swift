//

import Foundation

public enum BizumAttachmentImageType: String, Codable {
    case png
    case jpg
    case gif
    case noImage = ""
}

public struct BizumSendImageTextInputDTO: Codable {
    let checkPayment: BizumCheckPaymentDTO
    let validateTransferDTO: BizumValidateMoneyTransferDTO
    let receiverUserId: String
    let image: String?
    let imageFormat: BizumAttachmentImageType?
    let text: String?
}
