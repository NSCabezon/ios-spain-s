import CoreFoundationLib

final class PersonalManagerMainModuleCoordinatorImp: PersonalManagerMainModuleCoordinatorDelegate {
    func canOpenUrl(_ url: String) -> Bool {
        true
    }
    
    func handleOpinator(_ opinator: OpinatorInfoRepresentable) {
        
    }
    
    func didSelectOffer(offer: OfferEntity) {
        
    }
    
    func showDialog(acceptTitle: LocalizedStylableText?, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText?, showsCloseButton: Bool, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {
    }
    
    func didSelectDismiss() { }
    func didSelectMenu() { }
    func didSelectSearch() { }
    func open(url: String) { }
    func openAppStore(appId id: Int) { }
    func openChatWith(configuration: WebViewConfiguration) { }
    func showLoading(completion: (() -> Void)?) { completion?() }
    func hideLoading(completion: (() -> Void)?) { completion?() }
}
