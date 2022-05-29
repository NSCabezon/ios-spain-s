import UIKit
import UI

protocol ImageListFullscreenPresenterProtocol {
    func buttonPressed()
    func buttonSelected()
}

class ImageListFullscreenViewController: BaseViewController<ImageListFullscreenPresenterProtocol>, UIPageViewControllerDelegate {
    @IBOutlet weak var pageControlContainerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageContainer: UIView!
    
    lazy var imageListFullscreenContainerPageViewController: ImageListFullscreenContainerPageViewController = {
        return ImageListFullscreenContainerPageViewController.create()
    }()
    
    var pages: [ImageListFullscreenPageViewController]!
    
    override class var storyboardName: String {
        return "ImageListFullscreen"
    }
    
    override var navigationBarStyle: NavigationBarBuilder.Style {
        if #available(iOS 11.0, *) {
            return .clear(tintColor: .santanderRed)
        } else {
            return .custom(background: NavigationBarBuilder.Background.color(UIColor.white), tintColor: UIColor.santanderRed)
        }
    }
        
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = .sky30
        pageControlContainerView.backgroundColor = UIColor.uiBlack.withAlphaComponent(0.4)
        pageControl.pageIndicatorTintColor = .lisboaGray
        pageControl.currentPageIndicatorTintColor = .sanRed
        pageContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerViewPressed)))
    }
    
    @objc override func closeButtonTouched() {
        presenter.buttonPressed()
    }
    
    func addPages(pages: [ImageListFullscreenPageViewController], selectedPosition: Int) {
        setViewController(imageListFullscreenContainerPageViewController)
        imageListFullscreenContainerPageViewController.pages = pages
        imageListFullscreenContainerPageViewController.pageControl = pageControl
        pageControlContainerView.isHidden = pages.count == 1
        imageListFullscreenContainerPageViewController.selectedViewController(pages[selectedPosition])
    }
    
    func setPageControl(count: Int) {
        pageControl.isHidden = count <= 1
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = .lisboaGray
        pageControl.currentPageIndicatorTintColor = .sanRed
        pageControl.numberOfPages = count
        pageControl.currentPage = 0
        if #available(iOS 14.0, *) {
            pageControl.backgroundStyle = .minimal
        }
    }
    
    private func setViewController(_ viewController: UIViewController) {
        guard let newView = viewController.view else {
            return
        }
        addChild(viewController)
        newView.frame = pageContainer.bounds
        pageContainer.addSubview(newView)
        viewController.didMove(toParent: self)
    }
    
    @objc private func containerViewPressed() {
        presenter.buttonSelected()
    }
}

extension ImageListFullscreenViewController: ActionClosableProtocol {}
extension ImageListFullscreenViewController: NavigationBarCustomizable {}
