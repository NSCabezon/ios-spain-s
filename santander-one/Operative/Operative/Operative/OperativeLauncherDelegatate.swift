import CoreFoundationLib

public protocol OperativeLauncherHandler: AnyObject {
    var operativeNavigationController: UINavigationController? { get }
    var dependenciesResolver: DependenciesResolver { get }
    func showOperativeLoading(completion: @escaping () -> Void)
    func hideOperativeLoading(completion: @escaping () -> Void)
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?)
}
