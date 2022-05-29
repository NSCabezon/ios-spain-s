class DualContainerPresenter<View1, Navigator, Contract1, View2, Contract2>: PrivatePresenter<DualContainerViewController, Navigator, DualContainerPresenterProtocol> where View1: BaseViewController<Contract1>, View2: BaseViewController<Contract2> {
    
    var presenterOption1: PrivatePresenter<View1, Navigator, Contract1>?
    var presenterOption2: PrivatePresenter<View2, Navigator, Contract2>?
    
    override func loadViewData() {
        super.loadViewData()
        view.viewController1 = presenterOption1?.view
        view.viewController2 = presenterOption2?.view
    }
    
    // MARK: - DualContainerPresenterProtocol
    
    var optionTitle1: LocalizedStylableText {
        fatalError()
    }
    
    var optionTitle2: LocalizedStylableText {
        fatalError()
    }
    
    var title: String? {
        return nil
    }

}

extension DualContainerPresenter: Presenter {
    
}

extension DualContainerPresenter: DualContainerPresenterProtocol {
    
    func toggleSideMenu() {
        // I need this cast because generics make things hard
        (navigator as? MenuNavigator)?.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
    
}
