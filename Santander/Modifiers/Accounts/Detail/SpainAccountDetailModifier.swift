import CoreFoundationLib
import Account

final class SpainAccountDetailModifier: AccountDetailModifierProtocol {
    var isEnabledEditAlias: Bool = true
    var isEnabledAccountHolder: Bool = true
    var isEnabledMillionFormat: Bool = true
    
    func customAccountDetailBuilder(data: AccountDetailDataViewModel, isEnabledEditAlias: Bool) -> [AccountDetailProduct]? {
        nil
    }
}
