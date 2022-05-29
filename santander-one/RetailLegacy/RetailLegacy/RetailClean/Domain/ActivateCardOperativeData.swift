import Foundation

class ActivateCardOperativeData: ProductSelection<Card> {
    
    var expirationDate: Date?
    var activateCard: ActivateCard?
    let launchedFrom: OperativeLaunchedFrom
    var errorDesc: String?
    
    init(card: Card?, launchedFrom: OperativeLaunchedFrom) {
        self.launchedFrom = launchedFrom
        super.init(list: [], productSelected: card, titleKey: "toolbar_title_activate", subTitleKey: "deeplink_label_selectOriginCard")
    }
}
