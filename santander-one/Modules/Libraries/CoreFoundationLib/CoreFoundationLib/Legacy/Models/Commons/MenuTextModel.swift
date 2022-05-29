public enum MenuTextModel: String, CaseIterable {
    case menu = "menuText"
    case mailBox = "mailboxText"
    case search = "globalSearchText"
    
    public var allCases: [MenuTextModel] {
        return [.menu, .mailBox, .search]
    }
}
