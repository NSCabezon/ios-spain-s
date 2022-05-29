class StocksAlertsConfigurationPresenter: PrivatePresenter<LandingViewController, StocksAlertsConfigurationNavigatorProtocol, LandingPresenterProtocol>, SingleSignOn {
    var appStoreNavigator: AppStoreNavigatable {
        return navigator
    }
    
    private var landingAction: (() -> Void)?
    
    override func loadViewData() {
        super.loadViewData()
        
        landingAction = { [weak self] in
            self?.openSingleSignOn(type: .broker, parameters: nil)
        }
    }
}

// MARK: - LandingPresenterProtocol

extension StocksAlertsConfigurationPresenter: LandingPresenterProtocol {
    
    var title: LocalizedStylableText? {
        return stringLoader.getString("toolbar_title_landingSofiaAlerts")
    }
    
    var descriptionText: LocalizedStylableText? {
        return stringLoader.getString("landing_text_sofiaAlerts")
    }
    
    var graphics: LandingGraphicsInfo {
        return LandingGraphicsInfo(backgroundImage: "background_sofia", phoneImage: "iphoneLandingBrokerAlerts")
    }
    
    var button: LandingButtonInfo? {
        return LandingButtonInfo(title: stringLoader.getString("landing_button_sofia"), action: landingAction)
    }
}

// MARK: - SideMenuCapable

extension StocksAlertsConfigurationPresenter: SideMenuCapable {
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}
