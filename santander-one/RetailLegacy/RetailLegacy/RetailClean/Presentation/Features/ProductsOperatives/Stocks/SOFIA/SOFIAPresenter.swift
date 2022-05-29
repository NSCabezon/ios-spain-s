class SOFIAPresenter: PrivatePresenter<LandingViewController, SOFIANavigatorProtocol, LandingPresenterProtocol>, SingleSignOn {
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

extension SOFIAPresenter: LandingPresenterProtocol {
    
    var title: LocalizedStylableText? {
        return stringLoader.getString("toolbar_title_landingSofia")
    }
    
    var descriptionText: LocalizedStylableText? {
        return stringLoader.getString("landing_text_sofia")
    }
    
    var graphics: LandingGraphicsInfo {
        return LandingGraphicsInfo(backgroundImage: "background_sofia", phoneImage: "iphoneLandingBroker")
    }
    
    var button: LandingButtonInfo? {
        return LandingButtonInfo(title: stringLoader.getString("landing_button_sofia"), action: landingAction)
    }
}

// MARK: - SideMenuCapable

extension SOFIAPresenter: SideMenuCapable {
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}
