public protocol ActionButtonFillViewModelProtocol {
    var viewType: ActionButtonFillViewType { get }
}

extension ActionButtonFillViewModelProtocol {
    @available(*, deprecated, message: "use getAccessibilityIdentifier, and complete if needed")
    public func getAccessibilityValue() -> String? {
        switch self.viewType {
        case .defaultButton(let model):
            return model.accessibilityButtonValue
        case .defaultWithBackground(let model):
            return model.title
        case .offer,
             .centeredImage, .none:
            return nil
        }
    }
    
    public func getAccessibilityIdentifier() -> String? {
        switch self.viewType {
        case .defaultButton(let model):
            return model.accessibilityButtonValue
        default: return nil
        }
    }
}

public struct ActionButtonFillViewModel: ActionButtonFillViewModelProtocol {
    public let viewType: ActionButtonFillViewType
    
    public init(viewType: ActionButtonFillViewType) {
        self.viewType = viewType
    }
}
