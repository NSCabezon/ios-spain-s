import UIKit

protocol SplashPresenterContract: Presenter {
    
}

class SplashViewController: BaseViewController<SplashPresenterContract> {
    @IBOutlet weak var splashImageView: UIImageView!
    
    override class var storyboardName: String {
        return "Splash"
    }
    
    override func prepareView() {
        splashImageView.setSplashImage()
    }
}

extension SplashViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return false
    }
}
