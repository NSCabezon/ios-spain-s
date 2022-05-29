import UIKit

protocol ImageListFullscreenContainerPageViewDelegate: AnyObject {
    func selectedPage(index: Int)
}
class ImageListFullscreenContainerPageViewController: UIPageViewController {
    var actionDelegate: ImageListFullscreenContainerPageViewDelegate?
    var pages: [ImageListFullscreenPageViewController]?
    var pageControl: UIPageControl?
    var currentIndex: Int?
    private var transitionInProgress: Bool = false
    private var pendingIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        view.backgroundColor = .uiBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    class var storyboardName: String {
        return "ImageListFullscreen"
    }
    
    class func create() -> ImageListFullscreenContainerPageViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: .module)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? ImageListFullscreenContainerPageViewController else {
            fatalError("View Controller not found!!")
        }
        return viewController
    }
    
    class var viewControllerIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    func selectedViewController(_ viewController: ImageListFullscreenPageViewController) {
        setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
    }
}

extension ImageListFullscreenContainerPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let pages = pages, let index = pages.firstIndex(where: {$0 == pendingViewControllers.first as? ImageListFullscreenPageViewController}) else { return }
        pendingIndex = index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        currentIndex = pendingIndex
        if let index = currentIndex, let pageControl = pageControl {
            pageControl.currentPage = index
            actionDelegate?.selectedPage(index: index)
        }
    }
}

extension ImageListFullscreenContainerPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pages = pages, let index = pages.firstIndex(where: {$0 == viewController as? ImageListFullscreenPageViewController}) else { return nil }
        let previousIndex = index-1
        guard previousIndex >= 0, pages.count > previousIndex else { return nil }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pages = pages, let index = pages.firstIndex(where: {$0 == viewController as? ImageListFullscreenPageViewController}) else { return nil }
        let nextIndex = index+1
        guard nextIndex < pages.count, pages.count > nextIndex else { return nil }
        return pages[nextIndex]
    }
}
