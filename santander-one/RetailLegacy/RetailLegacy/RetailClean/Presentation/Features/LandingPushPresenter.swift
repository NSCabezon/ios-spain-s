import Foundation
import CoreFoundationLib

enum AlertInfoName: String {
    case payInCommerce = "0037"
    case cancelBuy = "0038"
    case tradeCommerce = "0038-1"
    case buy = "0039"
    case withDrawCode = "0040"
    case cancelWithDrawCode = "0042"
    
    var key: String {
        switch self {
        case .payInCommerce:
            return "landingPush_label_0037"
        case .cancelBuy:
            return "landingPush_label_0038"
        case .tradeCommerce:
            return "landingPush_label_0038_1"
        case .buy:
            return "landingPush_label_0039"
        case .withDrawCode:
            return "landingPush_label_0040"
        case .cancelWithDrawCode:
            return "landingPush_label_0042"
        }
    }
}

class LandingPushPresenter: PrivatePresenter<LandingPushViewController, LandingPushLauncherNavigator, LandingPushPresenterProtocol> {
    var cardTransactionInfo: CardTransactionPush?
    var cardAlertInfo: CardAlertPush?
    override var shouldRegisterAsDeeplinkHandler: Bool {
        return false
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.LandingPushCardMovement().page
    }
    
    init(cardTransactionInfo: CardTransactionPush?, cardAlertInfo: CardAlertPush?, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: LandingPushLauncherNavigator) {
        self.cardTransactionInfo = cardTransactionInfo
        self.cardAlertInfo = cardAlertInfo
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        let day = dependencies.timeManager.toString(input: cardTransactionInfo?.date, inputFormat: TimeFormat.ddMMyyyy_HHmmss, outputFormat: .dd_MM_yyyy)
        let hour = dependencies.timeManager.toString(input: cardTransactionInfo?.date, inputFormat: TimeFormat.ddMMyyyy_HHmmss, outputFormat: .HHmm)
        let sectionHeader = TableModelViewSection()
        let header = LandingPushHeaderViewModel(
            alertName: getAlertName(),
            commerce: cardTransactionInfo?.commerce ?? "",
            amount: getAmount()?.getFormattedAmountUI(2) ?? "",
            day: day,
            hour: hour,
            image: getImageCard() ?? "",
            cardType: getTypeCard(),
            cardName: cardTransactionInfo?.cardName.uppercased() ?? "",
            cardPan: "***\(cardTransactionInfo?.pan ?? "")",
            userName: cardAlertInfo?.user.uppercased() ?? "",
            dependencies: dependencies,
            imageURL: buildImageRelativeUrl(self.cardTransactionInfo, false),
            imageLoader: dependencies.imageLoader
        )
        sectionHeader.items = [header]
        let payLaterDeeplinkModel = LandingPushDeeplinkViewModel(deeplinkName: stringLoader.getString("landingPush_label_easyPay"), icnImage: "icnPostpone", isBold: true, deeplink: .easyPay, dependencies: dependencies)
        let turnOffDeeplinkModel = LandingPushDeeplinkViewModel(deeplinkName: stringLoader.getString("landingPush_label_cardOff"), icnImage: "icnOffCard", deeplink: .turnOffCard, dependencies: dependencies)
        let paymentMethodDeeplinkModel = LandingPushDeeplinkViewModel(deeplinkName: stringLoader.getString("landingPush_label_paymentMethod"), icnImage: "icnPaymentMethod", deeplink: .changeCardPayMethod, dependencies: dependencies)
        let codeWithdrawDeeplinkModel = LandingPushDeeplinkViewModel(deeplinkName: stringLoader.getString("landingPush_label_codeMoney"), icnImage: "icnWithdrawMoney", deeplink: .withdrawMoneyWithCode, dependencies: dependencies)
        let fraudFeedbackDeeplinkModel = LandingPushDeeplinkViewModel(deeplinkName: stringLoader.getString("landingPush_label_fraud"), icnImage: "icnBlueFraud", deeplink: .offerLink(identifier: "REPORTAR_FRAUDE", location: nil), dependencies: dependencies)
        let pinQueryDeeplinkModel = LandingPushDeeplinkViewModel(deeplinkName: stringLoader.getString("landingPush_label_pin"), icnImage: "icnPinLanding", deeplink: .pinQuery, dependencies: dependencies)
        let sectionContent = TableModelViewSection()
        guard let cardType = cardTransactionInfo?.getCardType() else { return }
        switch cardType {
        case .credit:
            guard let amount = getAmount(), let value = amount.value else { return }
            if value > Decimal(60) && amount.currencyName == "EUR" {
                sectionContent.items += [payLaterDeeplinkModel, turnOffDeeplinkModel, paymentMethodDeeplinkModel, fraudFeedbackDeeplinkModel]
            } else {
                sectionContent.items += [turnOffDeeplinkModel, paymentMethodDeeplinkModel, fraudFeedbackDeeplinkModel]
            }
        case .debit:
            sectionContent.items += [turnOffDeeplinkModel, codeWithdrawDeeplinkModel, fraudFeedbackDeeplinkModel, pinQueryDeeplinkModel]
        case .other:
            sectionContent.items += [turnOffDeeplinkModel, fraudFeedbackDeeplinkModel]
        }
        view.sections = [sectionHeader, sectionContent]
        LandingPushPresenter.trackMetricsLocation(dependencies: dependencies)
    }
    
    static func trackMetricsLocation(dependencies: PresentationComponent) {
        let screenId: String = TrackerPagePrivate.LandingPushCardMovement().page
        let eventId: String = TrackerPagePrivate.Generic.Action.get_location.rawValue
        if dependencies.locationManager.locationServicesStatus() == .authorized {
            dependencies.locationManager.getCurrentLocation { latitudeResponse, longitudeResponse in
                let latitude: String = "\(latitudeResponse ?? 0)"
                let longitude: String = "\(longitudeResponse ?? 0)"
                let extraParameters: [String: String] = [TrackerDimensions.latitude: latitude, TrackerDimensions.longitude: longitude]
                dependencies.trackerManager.trackEvent(screenId: screenId, eventId: eventId, extraParameters: extraParameters)
            }
        } else {
            let extraParameters: [String: String] = [TrackerDimensions.latitude: "", TrackerDimensions.longitude: ""]
            dependencies.trackerManager.trackEvent(screenId: screenId, eventId: eventId, extraParameters: extraParameters)
        }
    }
    
    func getTypeCard() -> LocalizedStylableText? {
        guard let cardType = cardTransactionInfo?.getCardType() else { return nil }
        switch cardType {
        case .credit:
            return stringLoader.getString("landingPush_label_creditCard")
        case .debit:
            return stringLoader.getString("landingPush_label_debitCard")
        case .other:
            return nil
        }        
    }
    
    func getImageCard() -> String? {
        return "defaultCard"
    }
    
    private func buildImageRelativeUrl(_ cardTransaction: CardTransactionPush?, _ miniature: Bool) -> String? {
        if let productCode = cardTransaction?.cardPlasticCode {
            return Card.Constants.CardImage.relativeURl
                + productCode
                + Card.Constants.CardImage.fileExtension
        }
        
        guard let productCode = cardTransaction?.productCode, let subProductCode = cardTransaction?.subProductCode else {
            return nil
        }
        return Card.Constants.CardImage.relativeURl
            + productCode + subProductCode
            + Card.Constants.CardImage.fileExtension
    }
    
    private func getAmount() -> Amount? {
        guard let value = cardTransactionInfo?.value,
              let currency = cardTransactionInfo?.currency,
              let decimal = Decimal(string: value)
        else {
            return nil
        }
        let amount = Amount.create(value: decimal, currency: Currency.create(withName: currency))
        return amount
    }
    
    private func getAlertName() -> LocalizedStylableText {
        return stringLoader.getString(AlertInfoName(rawValue: cardAlertInfo?.name ?? "")?.key ?? "")
    }
}

extension LandingPushPresenter: Presenter {}
extension LandingPushPresenter: LandingPushPresenterProtocol {
    func goToAppPressed() {
        self.view.dismiss(animated: true)
    }
    
    func closePressed() {        
        self.view.dismiss(animated: true)
    }
    
    func selected(index: Int) {
        guard let deeplinkOption = view.itemsSectionContent()[index] as? LandingPushDeeplinkViewModel else {
            return
        }
        dependencies.deepLinkManager.registerDeepLink(deeplinkOption.deeplink)
        dependencies.navigatorProvider.dependenciesEngine
        if let trackerId = deeplinkOption.deeplink.trackerId {
            dependencies.trackerManager.trackEvent(screenId: screenId ?? "", eventId: TrackerPagePrivate.LandingPushCardMovement.Action.deeplink.rawValue, extraParameters: [TrackerDimensions.deeplinkLogin: trackerId])
        }
        self.view.dismiss(animated: true)
    }
}
