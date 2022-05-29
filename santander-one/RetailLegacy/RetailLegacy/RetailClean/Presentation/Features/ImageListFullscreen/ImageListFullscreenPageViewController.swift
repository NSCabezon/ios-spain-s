import UIKit
import UI

protocol ImageListFullscreenPagePresenterProtocol: Presenter {}

class ImageListFullscreenPageViewController: BaseViewController<ImageListFullscreenPagePresenterProtocol> {    
    @IBOutlet weak var imageView: UIImageView!
    override class var storyboardName: String {
        return "ImageListFullscreen"
    }
    
    override func prepareView() {
        super.loadView()
        view.backgroundColor = .sky30
    }
    
    override var navigationBarStyle: NavigationBarBuilder.Style {
        if #available(iOS 11.0, *) {
            return .clear(tintColor: .santanderRed)
        } else {
            return .custom(background: NavigationBarBuilder.Background.color(UIColor.white), tintColor: UIColor.santanderRed)
        }
    }
}
