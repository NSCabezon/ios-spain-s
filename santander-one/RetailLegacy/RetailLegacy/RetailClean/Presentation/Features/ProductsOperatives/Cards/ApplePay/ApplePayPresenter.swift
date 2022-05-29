class ApplePayPresenter: PrivatePresenter<LandingViewController, ApplePayNavigatorProtocol, LandingPresenterProtocol> {
    override var screenId: String? {
        return TrackerPagePrivate.CardsApplePay().page
    }
}

// MARK: - LandingPresenterProtocol

extension ApplePayPresenter: LandingPresenterProtocol {
    
    var title: LocalizedStylableText? {
        return stringLoader.getString("toolbar_title_landingPay")
    }
    
    var descriptionText: LocalizedStylableText? {
        return stringLoader.getString("landing_text_pay_ios")
    }
    
    var graphics: LandingGraphicsInfo {
        return LandingGraphicsInfo(backgroundImage: "background_apple_pay", phoneImage: "iphoneLandingApplePay")
    }
    
    var button: LandingButtonInfo? {
        return nil
    }
}

// MARK: - SideMenuCapable

extension ApplePayPresenter: SideMenuCapable {
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}
