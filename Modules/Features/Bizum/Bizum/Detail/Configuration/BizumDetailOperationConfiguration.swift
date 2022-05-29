import Foundation
import CoreFoundationLib

final class BizumDetailOperationConfiguration {
    let contacts: [BizumContactEntity]
    init(contacts: [BizumContactEntity]) {
        self.contacts = contacts
    }
}
