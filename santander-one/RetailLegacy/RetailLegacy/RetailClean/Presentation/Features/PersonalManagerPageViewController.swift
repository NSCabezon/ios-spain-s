//

import UIKit

protocol PersonalManagerPageViewProtocol {
    
}

class PersonalManagerPageViewController: UIPageViewController, PersonalManagerPageViewProtocol {
    
    var pages: [UIViewController]?
    var presenter: PersonalManagerContainerPresenterProtocol?

    private var transitionInProgress: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }
    
    class var storyboardName: String {
        return "PersonalManager"
    }
    
    class func create() -> PersonalManagerPageViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: .module)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? PersonalManagerPageViewController else {
            fatalError("ViewController not found!")
        }
        return viewController
    }
    
    class var viewControllerIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    func selectedViewController(_ viewController: UIViewController, direction: UIPageViewController.NavigationDirection) -> Bool {
        guard !transitionInProgress else {
            return false
        }
        if viewController == viewControllers?.first {
            return true
        }
        transitionInProgress = true
        setViewControllers([viewController], direction: direction, animated: true, completion: { [weak self] (completion) in
            guard completion, let strongself = self else {
                return
            }
            strongself.transitionInProgress = false
        })
        return true
    }
}

extension PersonalManagerPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pages = pages, let index = pages.firstIndex(where: {$0 == viewController}) else { return nil }
        let previousIndex = index-1
        guard previousIndex >= 0, pages.count > previousIndex else { return nil }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pages = pages, let index = pages.firstIndex(where: {$0 == viewController}) else { return nil }
        let nextIndex = index+1
        guard nextIndex < pages.count, pages.count > nextIndex else { return nil }
        return pages[nextIndex]
    }
}

extension PersonalManagerPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        transitionInProgress = true
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        transitionInProgress = false
        guard completed, let viewController = pageViewController.viewControllers?.first, let index = pages?.firstIndex(of: viewController) else { return }
        presenter?.currentPosition(at: index)
    }
}
