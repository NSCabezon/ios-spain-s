import CoreFoundationLib
import CoreDomain

final class MenuAtmCoordinatorMock: AtmCoordinatorDelegate {
    func didSelectMenu() {
    }
    
    func didSelectDismiss() {
    }
    
    func didSelectSearch() {
    }
    
    func didSelectedGetMoneyWithCode() {
    }
    
    func didSelectedCardLimitManagement() {
    }
    
    func didSelectOffer(_ offer: OfferEntity?) {
    }
    
    func didSelectSearchAtm() {
    }
    
    func goToHomeTips() {
    }
    
    func goToSettings(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText, title: LocalizedStylableText?, body: LocalizedStylableText, cancelAction: (() -> Void)?) {
    }
    func didSelectOffer(_ offer: OfferRepresentable?) {}
}
