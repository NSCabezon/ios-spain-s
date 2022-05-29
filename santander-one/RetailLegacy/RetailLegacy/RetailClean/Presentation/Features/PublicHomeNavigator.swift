import CoreDomain
import CoreFoundationLib

protocol PublicHomeNavigator: PublicNavigatable, PullOffersActionsNavigatorProtocol {
    func goToFeatureFlags()
    func goToEnvironmentsSelector(completion: @escaping () -> Void)
    func goToPrivate(globalPositionOption: GlobalPositionOptionEntity)
    func goToFakePrivate(_ isPb: Bool, _ name: String?)
    func backToLogin()
    func goToURL(source: String)
    func goToOtpSca(username: String, isFirstTime: Bool)
    func goToQuickBalance()
    func reloadSideMenu()
}
