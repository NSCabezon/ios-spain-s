public protocol PrivateSubmenuOptionRepresentable {
    var titleKey: String { get }
    var icon: String? { get }
    var iconURL: String? { get }
    var submenuArrow: Bool { get }
    var isInnerTitle: Bool { get }
}

public extension PrivateSubmenuOptionRepresentable {
    var iconURL: String? {
        return nil
    }
    var submenuArrow: Bool {
        return false
    }
    var isInnerTitle: Bool {
        return false
    }
}

public protocol PrivateSubmenuOptionHelperRepresentable {
    var titleKey: String { get }
    var superTitleKey: String? { get }
    var sidebarProductsTitle: String? { get }
    var hasTitle: Bool { get }
    func getOptionsList(completion: @escaping ([PrivateSubmenuOptionRepresentable]) -> Void)
    func selected(option: PrivateSubmenuOptionRepresentable)
    func titleForOption(_ option: PrivateSubmenuOptionRepresentable) -> String
}

public extension PrivateSubmenuOptionHelperRepresentable {
    var superTitleKey: String? {
        return nil
    }
}
