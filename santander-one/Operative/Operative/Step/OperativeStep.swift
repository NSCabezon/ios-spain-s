public enum OperativeStepPresentationType {
    case inNavigation(showsBack: Bool, showsCancel: Bool)
    case modal
}

public protocol OperativeStep {
    var presentationType: OperativeStepPresentationType { get }
    var view: OperativeView? { get }
    var floatingButtonTitleKey: String { get }
    var shouldCountForProgress: Bool { get }
    var shouldCountForContinueButton: Bool { get }
}

extension OperativeStep {
    public var floatingButtonTitleKey: String { return "" }
    public var shouldCountForProgress: Bool { return true }
    public var shouldCountForContinueButton: Bool { return true }
}
