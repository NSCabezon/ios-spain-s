public protocol BaseMenuController {
    var currentRootViewController: (UIViewController & RootMenuController)? { get }
}
