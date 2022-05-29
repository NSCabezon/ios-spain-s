/// Protocol implemented to indicate that side menu (swipe gesture) should be used to display the menu
/// ViewController must implement RootMenuController Protocol 
protocol SideMenuCapable {
    func toggleSideMenu()
    var isSideMenuAvailable: Bool { get }
}
