import UIKit

class TransactionDetailPageViewController: UIPageViewController {
    
    var pages: [TransactionDetailViewController]?
    private var transitionInProgress: Bool = false
    
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
        return "TransactionDetail"
    }
    
    class func create() -> TransactionDetailPageViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: .module)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? TransactionDetailPageViewController else {
            fatalError("View Controller not found!!")
        }
        return viewController
    }

    class var viewControllerIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    func selectedViewController(_ viewController: TransactionDetailViewController) {
        setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
        configureButtons(viewController)
    }
    
    func goToNextPage() {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) else { return }
        guard !transitionInProgress else { return }
        transitionInProgress = true
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: { [weak self] _ in
            guard let presenter = self else { return }
            presenter.transitionInProgress = false
        })
        configureButtons(nextViewController as! TransactionDetailViewController)
    }
    
    func goToPreviousPage() {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController(self, viewControllerBefore: currentViewController) else { return }
        guard !transitionInProgress else { return }
        transitionInProgress = true
        setViewControllers([previousViewController], direction: .reverse, animated: true, completion: { [weak self] _ in
            guard let presenter = self else { return }
            presenter.transitionInProgress = false
        })
        configureButtons(previousViewController as! TransactionDetailViewController)
    }
    
    private func configureButtons(_ viewController: TransactionDetailViewController) {
        if let index = pages?.firstIndex(of: viewController), let parent = parent as? TransactionDetailContainerViewController, let count = pages?.count {
            if count == 1 {
                parent.previousButton.isHidden = true
                parent.nextButton.isHidden = true
            } else if index == 0 {
                parent.previousButton.isHidden = true
                parent.nextButton.isHidden = false
            } else if index == count-1 {
                parent.previousButton.isHidden = false
                parent.nextButton.isHidden = true
            } else {
                parent.previousButton.isHidden = false
                parent.nextButton.isHidden = false
            }
        }
    }
}

extension TransactionDetailPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        transitionInProgress = true
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        transitionInProgress = false
    }
}

extension TransactionDetailPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pages = pages, let index = pages.firstIndex(where: {$0 == viewController as? TransactionDetailViewController}) else { return nil }
        let previousIndex = index-1
        configureButtons(viewController as! TransactionDetailViewController)
        guard previousIndex >= 0, pages.count > previousIndex else { return nil }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pages = pages, let index = pages.firstIndex(where: {$0 == viewController as? TransactionDetailViewController}) else { return nil }
        let nextIndex = index+1
        configureButtons(viewController as! TransactionDetailViewController)
        guard nextIndex < pages.count, pages.count > nextIndex else { return nil }
        return pages[nextIndex]
    }
    
}
