import UIKit
import CoreFoundationLib
import Transfer
import UI
import CoreDomain

protocol PrivateHomeNavigator: PublicNavigatable, ModalViewsObserverProtocol, OperativesNavigatorProtocol, SystemSettingsNavigatable, GenericErrorDialogCoordinatorDelegate {
    func present(selectedProduct: GenericProduct?, productHome: PrivateMenuProductHome)
    func showCardTransaction(_ transaction: CardTransactionEntity, in transactions: [CardTransactionWithCardEntity], for entity: CardEntity)
    func showAccountTransaction(_ transaction: AccountTransactionEntity, in transactions: [AccountTransactionWithAccountEntity], for entity: AccountEntity, associated: Bool)
    func backToGlobalPosition()
    func setOnlyFirstViewControllerToGP()
    func setFirstViewControllerToGP()
    func goToManager()
    func goToVariableIncome()
    func goToPersonalArea()
    func goToWhatsNew()
    func goToWhatsNewFractionalMovements()
    func goToSecuritySettings()
    func goToConfigureGP()
    func goToProductsCustomization()
    func goToDigitalProfile()
    func goToUserBasicInfo()
    func goToSecureDevice(device: OTPPushDeviceEntity?)
    func goToSecureDeviceOperative()
    func goToServicesForYou(with category: Category)
    func goToGlobalSearch()
    func presentOverCurrentController(selectedProduct: GenericProduct?, productHome: PrivateMenuProductHome)
    func goToVisualOptions()
    func open(url: String)
    func goToChangeDirectLinkConfiguration()
    func goToOnboarding(delegate: OnboardingDelegate, onboardingUserData: OnboardingUserData)
    func goToStockholders()
    func goToFutureBill(_ bill: AccountFutureBillRepresentable, in bills: [AccountFutureBillRepresentable], for entity: AccountEntity)
    func didSelectContact(_ contact: PayeeRepresentable, launcher: ModuleLauncher, delegate: ModuleLauncherDelegate)
    func goToHistoricSendMoney()
    func showComingSoonToast()
    func gotoCardSubcriptions()
    func goToTips()
    func gotoNextSettlement(_ cardEntity: CardEntity, cardSettlementDetailEntity: CardSettlementDetailEntity, isEnabledMap: Bool)
    func gotoCardEasyPayOperative(card: CardEntity, transaction: CardTransactionEntity, easyPayOperativeData: EasyPayOperativeDataEntity?)
    func goToFractionedPaymentDetail(transaction: CardTransactionEntity, card: CardEntity)
}

protocol PrivateHomeNavigatorSideMenu: ShowingDialogOnCenterViewCapable {
    var drawerRoot: RootableViewController? { get }
    var highlight: HighlightedMenuProtocol? { get }
    func drawerRoot<T>(as: T.Type) -> T?
    func goToMyProducts(privateMenuWrapper: PrivateMenuWrapper, offerDelegate: PrivateSideMenuOfferDelegate)
    func goToSofiaInvestment(privateMenuWrapper: PrivateMenuWrapper, offerDelegate: PrivateSideMenuOfferDelegate)
    func goToOtherServices(privateMenuWrapper: PrivateMenuWrapper, offerDelegate: PrivateSideMenuOfferDelegate, comingFeatures: Bool)
    func goToWorld123(privateMenuWrapper: PrivateMenuWrapper, offerDelegate: PrivateSideMenuOfferDelegate, comingFeatures: Bool)
    func goToContractView()
    func goToHelpCenter()
    func goToServicesForYouHelper(offerDelegate: PrivateSideMenuOfferDelegate) 
    func popToFirstLevel(animated: Bool)
    func goBack(animated: Bool)
    func reloadPrivate()
    func goToAnalysisArea()
    func goToTransfers(section: TransferModuleCoordinator.TransferSection)
    func goToNewShipment()
    func goToInternalTransfers()
    func goToBillsAndTaxes()
    func goToATMLocator(keepingNavigation: Bool)
    func goToSecurityArea()
    func goToComingSoon()
    func goToFinancing()
    func goToAtm()
    func goToDirectDebitBillAndTaxes(_ account: AccountEntity?)
    func goToTimeline()
}

extension PrivateHomeNavigatorSideMenu {
    
    func popToFirstLevel() {
        popToFirstLevel(animated: true)
    }
    
    func goBack() {
        goBack(animated: true)
    }
    
}

protocol ShowingDialogOnCenterViewCapable {
    var drawer: BaseMenuViewController { get }
    func showDialogOnDrawer(title: LocalizedStylableText?, body: LocalizedStylableText, acceptButton: DialogButtonComponents, cancelButton: DialogButtonComponents?)
	func showDialogOnDrawer(title: LocalizedStylableText?, messageTitle message: LocalizedStylableText, subtext: LocalizedStylableText, withImage image: UIImage)
}

extension ShowingDialogOnCenterViewCapable {
    func showDialogOnDrawer(title: LocalizedStylableText?, body: LocalizedStylableText, acceptButton: DialogButtonComponents, cancelButton: DialogButtonComponents?) {
        Dialog.alert(title: title, body: body, withAcceptComponent: acceptButton, withCancelComponent: cancelButton, showsCloseButton: false, source: drawer)
    }
	
	//! Show dialog on drawer based on alert dialog
	func showDialogOnDrawer(title: LocalizedStylableText?, messageTitle message: LocalizedStylableText, subtext: LocalizedStylableText, withImage image: UIImage) {
		Dialog.alert(title: title, messageTitle: message, subtext: subtext, withImage: image, source: drawer)
	}
}
