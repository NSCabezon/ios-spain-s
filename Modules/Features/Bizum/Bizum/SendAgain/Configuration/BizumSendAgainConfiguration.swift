import Foundation
import CoreFoundationLib

final class BizumSendAgainConfiguration {
    let type: BizumEmitterType
    let contact: BizumContactEntity
    let sendMoney: BizumSendMoney
    let items: [BizumDetailItemsViewModel]

    init(_ type: BizumEmitterType, contact: BizumContactEntity, sendMoney: BizumSendMoney, items: [BizumDetailItemsViewModel]) {
        self.type = type
        self.contact = contact
        self.sendMoney = sendMoney
        self.items = items
    }
}
