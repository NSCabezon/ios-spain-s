import Foundation
import CoreFoundationLib

struct BizumSendAgainOperativeViewModel {
    let contact: BizumContactEntity
    let bizumSendMoney: BizumSendMoney

    init(contact: BizumContactEntity, bizumSendMoney: BizumSendMoney) {
        self.contact = contact
        self.bizumSendMoney = bizumSendMoney
    }

}
