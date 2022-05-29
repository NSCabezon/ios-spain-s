/// Protocol implemented to indicate that side menu (swipe gesture) should be used to display the menu
/// Presenter must implement SideMenuCapable Protocol
public protocol RootMenuController {
    var isSideMenuAvailable: Bool { get }
}
