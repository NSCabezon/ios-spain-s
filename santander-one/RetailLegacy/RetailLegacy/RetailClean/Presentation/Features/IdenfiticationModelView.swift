import CoreFoundationLib

struct IdenfiticationModelView: PickerElement, Equatable {
    
    var value: String {
        return stringLoader.getString(type.languageKey).text
    }
    var accessibilityIdentifier: String?
    
    let type: LoginIdentityDocumentType
    private let stringLoader: StringLoader
    
    init(type: LoginIdentityDocumentType, stringLoader: StringLoader) {
        self.type = type
        self.stringLoader = stringLoader
    }
    
    static func == (lhs: IdenfiticationModelView, rhs: IdenfiticationModelView) -> Bool {
        return lhs.type == rhs.type
    }
}

extension LoginIdentityDocumentType {
    var languageKey: String {
        switch self {
        case .nie:
            return "loading_select_nie"
        case .passport:
            return "loading_select_pasaporte"
        case .nif:
            return "loading_select_nif"
        case .cif:
            return "loading_select_cif"
        case .user:
            return "loading_select_user"
        }
    }
}
