import UI
import CoreFoundationLib

public class CardControlDistributionViewModel {
    var items: [CardControlDistributionItemViewModel]
    init() {
        self.items = CardControlDistributionViewModel.createViewModel()
    }
    
    private static func createViewModel () -> [CardControlDistributionItemViewModel] {
        [CardControlDistributionItemViewModel(title: localized("m4m_title_ecommerceCards"),
                                              description: localized("m4m_text_ecommerceCards"),
                                              imageName: "imgEcommerceCards",
                                              actions: ["m4m_label_seePayments",
                                                        "m4m_label_pauseOrResume",
                                                        "m4m_label_installmentPayments"],
                                              buttonText: localized("m4m_button_ecommerceCards"),
                                              type: .seeRecurringPaymentsList)
        ]
    }
    
    func addItemLocated(_ location: String) {
        switch location {
        case CardsPullOffers.suscriptionM4M:
            self.items.append(CardControlDistributionItemViewModel(
                                title: localized("m4m_title_controlYourSubscriptions"),
                                description: localized("m4m_text_controlYourSubscriptions"),
                                imageName: "imgSuscriptions",
                                actions: ["m4m_label_checkPayments",
                                          "m4m_label_setUpAlerts"],
                                buttonText: localized("m4m_button_subscriptions"),
                                type: .seeSubscriptions,
                                locationKey: CardsPullOffers.suscriptionM4M))
        default:
            break
        }
    }
}

struct CardControlDistributionItemViewModel {
    let title: String
    let description: String
    let imageName: String
    let actions: [String]
    let buttonText: String
    let type: CardControlDistributionType
    let locationKey: String?
    
    init(title: String, description: String, imageName: String, actions: [String], buttonText: String, type: CardControlDistributionType, locationKey: String? = nil) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.actions = actions
        self.buttonText = buttonText
        self.type = type
        self.locationKey = locationKey
    }
}
