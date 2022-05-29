//

import UIKit
typealias PageControlTitleConfig = (titleOne: LocalizedStylableText, titleTwo: LocalizedStylableText)
protocol PersonalManagerContainerPresenterProtocol: SideMenuCapable, Presenter {
    var pageControlTitles: PageControlTitleConfig { get }
    func currentPosition(at index: Int)
    var title: LocalizedStylableText { get }
    var isPageControlVisible: Bool? { get }
}

class PersonalManagerContainerViewController: BaseViewController<PersonalManagerContainerPresenterProtocol> {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var managerPageControl: PersonalManagerPageControl!
    @IBOutlet weak var heightPageControl: NSLayoutConstraint!
    
    override class var storyboardName: String {
        return "PersonalManager"
    }
    
    override func loadView() {
        super.loadView()
        styledTitle = presenter.title
        managerPageControl.setupTitleOne(with: presenter.pageControlTitles.titleOne,
                                         titleTwo: presenter.pageControlTitles.titleTwo)
        
    }
    
    lazy var personalManagerPageViewController: PersonalManagerPageViewController = {
        return PersonalManagerPageViewController.create()
    }()
    
    var pages: [UIViewController]!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        separatorView.addShadow(offset: CGSize(width: 1, height: 0), radius: 5, color: .uiBlack, opacity: 1, cornerRadius: 5)
    }

    func addPages(pages: [ManagerProfileProtocol]) {
        if let isPageControlVisible = presenter.isPageControlVisible, !isPageControlVisible {
            heightPageControl.constant = 0
            managerPageControl.isHidden = true
        }
        self.pages = pages as? [UIViewController]
        setViewController(personalManagerPageViewController)
        personalManagerPageViewController.pages = self.pages
        _ = personalManagerPageViewController.selectedViewController(self.pages[0], direction: .forward)
        personalManagerPageViewController.presenter = presenter
    }
    
    private func setViewController(_ viewController: UIViewController) {
        guard let newView = viewController.view else {
            return
        }
        addChild(viewController)
        newView.frame = containerView.bounds
        containerView.addSubview(newView)
        viewController.didMove(toParent: self)
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
    
}

extension PersonalManagerContainerViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
}
