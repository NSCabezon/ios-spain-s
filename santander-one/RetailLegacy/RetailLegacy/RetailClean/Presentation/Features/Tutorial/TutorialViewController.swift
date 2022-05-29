import UIKit

protocol TutorialPresenterProtocol {
    func buttonPressed()
}

class TutorialViewController: BaseViewController<TutorialPresenterProtocol>, UIPageViewControllerDelegate {
    @IBOutlet weak var pageContainer: UIView!
    @IBOutlet weak var bottomButton: RedButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var stackView: UIStackView!
    
    override class var storyboardName: String {
        return "Tutorial"
    }
    
    lazy var tutorialContainerPageViewController: TutorialContainerPageViewController = {
        return TutorialContainerPageViewController.create()
    }()
    
    var pages: [TutorialDetailViewController]!
    
    var titleButton: LocalizedStylableText? {
        didSet {
            if let text = titleButton {
                bottomButton.set(localizedStylableText: text, state: .normal)
            } else {
                bottomButton.isHidden = true
            }
        }
    }
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = .uiBackground
        bottomButton.set(localizedStylableText: stringLoader.getString("generic_button_understand"), state: .normal)
        bottomButton.onTouchAction = { [weak self] _ in
            self?.buttonTouched()
        }
        pageControl.pageIndicatorTintColor = .lisboaGray
        pageControl.currentPageIndicatorTintColor = .sanRed
    }
    
    @objc override func closeButtonTouched() {
        presenter.buttonPressed()
    }
    
    func buttonTouched() {
        presenter.buttonPressed()
    }
    
    func addPages(pages: [TutorialDetailViewController], selectedPosition: Int) {
        setViewController(tutorialContainerPageViewController)
        tutorialContainerPageViewController.pages = pages
        tutorialContainerPageViewController.pageControl = pageControl
        tutorialContainerPageViewController.selectedViewController(pages[selectedPosition])
    }
    
    func setPageControl(count: Int) {
        pageControl.isHidden = count <= 1
        pageControl.hidesForSinglePage = true
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
}

extension TutorialViewController: ActionClosableProtocol {}
