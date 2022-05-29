class FakePGpresenter: PrivatePresenter<FakePGViewController, PrivateHomeNavigator & PrivateHomeNavigatorSideMenu, FakePGViewPresenterContract> {
    
    var isPb = false
    var name: String?
    
    override var shouldRegisterAsDeeplinkHandler: Bool {
        return false
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.setCustomizeToolbar(isPB: isPb, name: name)
    }
  
    func backToLogin() {
        view.resetNavigationBar()
    }
}

extension FakePGpresenter: FakePGViewPresenterContract {}
