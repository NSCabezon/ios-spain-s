import CoreFoundationLib
import CoreDomain

final class PFMControllerMock: PfmControllerProtocol {
    
    var isFinish: Bool = false
    var monthsHistory: [MonthlyBalanceRepresentable]? = nil
    
    func removePFMSubscriber(_ subscriber: PfmControllerSubscriber) {}
    
    func isPFMAccountReady(account: AccountEntity) -> Bool {
        return true
    }
    
    func isPFMCardReady(card: CardEntity) -> Bool {
        return true
    }
    
    func registerPFMSubscriber(with subscriber: PfmControllerSubscriber) {}
    
    func cancelAll() {}
    
}
