public struct OperativeContainerDialog {
    static var empty: OperativeContainerDialog {
        return OperativeContainerDialog(titleKey: nil, descriptionKey: nil, acceptAction: nil)
    }
    var titleKey: String?
    var descriptionKey: String?
    var acceptAction: (() -> Void)?
}

/// The operative step presenter
public protocol OperativeStepPresenterProtocol: OperativeStepBackableCapable, OperativeStepProgressBarCapable {
    var number: Int { get set }
    var isBackButtonEnabled: Bool { get set }
    var isCancelButtonEnabled: Bool { get set }
    var container: OperativeContainerProtocol? { get set }
}

public protocol OperativeStepBackableCapable: AnyObject {
    var isBackable: Bool { get }
}

extension OperativeStepBackableCapable {
    public var isBackable: Bool {
        true
    }
}

public protocol OperativeStepProgressBarCapable: AnyObject {
    var shouldShowProgressBar: Bool { get }
}
 
extension OperativeStepProgressBarCapable {
    public var shouldShowProgressBar: Bool {
        true
    }
}
