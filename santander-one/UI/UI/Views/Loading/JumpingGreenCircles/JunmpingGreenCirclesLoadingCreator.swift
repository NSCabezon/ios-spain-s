import CoreFoundationLib

public class JunmpingGreenCirclesLoadingCreator {
    private static weak var loadingController: JumpingGreenCirclesLoadingViewController?
    
    public static func showGlobalLoading(_ settings: JumpingGreenCirclesLoadingViewController.Settings) {
        let loadingViewController = JumpingGreenCirclesLoadingViewController()
        loadingViewController.showLoading(settings: settings)
        setCurrentLoadingController(loadingViewController)
    }

    public static func isCurrentlyLoadingShowing() -> Bool {
        return self.loadingController != nil
    }
    
    public static func hideGlobalLoading(completion: (() -> Void)? = nil) {
        guard let loadingController = loadingController else {
            completion?()
            return
        }
        loadingController.hideLoading(completion: completion)
        self.loadingController = nil
    }
    
    private static func setCurrentLoadingController(_ currentLoadingViewController: JumpingGreenCirclesLoadingViewController) {
        if loadingController != nil {
            hideGlobalLoading()
        }
        loadingController = currentLoadingViewController
    }
}
