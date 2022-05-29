import Foundation

protocol TabContainerPresenterType: class, Presenter, ViewControllerProxy {
    var tabTitle: LocalizedStylableText { get }
    var tabIconKey: String? { get }
}

class TabContainerPresenter<Navigator: TabContainerNavigatorProtocol>: PrivatePresenter<TabContainerViewController, Navigator, TabContainerPresenterProtocol>, TabContainerPresenterProtocol {
    weak var lastPresenter: TabContainerPresenterType? 
    
    func didSelectListOption(_ option: Int) {}
}

extension TabContainerPresenter: SideMenuCapable {
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}
