//

import Foundation

struct BillEmittersPaymentConfirmationRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let language: String
    let dialect: String
    let account: AccountDTO
    let signature: SignatureDTO
    let amount: AmountDTO
    let emitterCode: String
    let productIdentifier: String
    let collectionTypeCode: String
    let collectionCode: String
    let billData: [String]
}
