import UIKit

protocol DualContainerPresenterProtocol: SideMenuCapable {
    var optionTitle1: LocalizedStylableText { get }
    var optionTitle2: LocalizedStylableText { get }
    var title: String? { get }
}

class DualContainerViewController: BaseViewController<DualContainerPresenterProtocol> {
    
    @IBOutlet weak var viewControllerContainer: UIView!
    @IBOutlet weak var optionButton1: UIButton!
    @IBOutlet weak var optionButton2: UIButton!
    @IBOutlet weak var selectorView: UIView!
    @IBOutlet weak var topMenuView: UIView!

    var viewController1: UIViewController? {
        didSet {
            updateTopMenu()
            guard viewController1 != nil else { return }
            buttonPressed(optionButton1)
        }
    }
    var viewController2: UIViewController? {
        didSet {
            updateTopMenu()
            guard viewController2 != nil && viewController1 == nil else { return }
            buttonPressed(optionButton2)
        }
    }
    var selectedOptionIndicatorColor: UIColor {
        return .sanRed
    }
    private var currentViewController: UIViewController?
    private var currentOptionIndicatorConstraint: NSLayoutConstraint?
    
    override class var storyboardName: String {
        return "DualContainer"
    }
    
    override func prepareView() {
        selectorView.backgroundColor = selectedOptionIndicatorColor
        optionButton1.set(localizedStylableText: presenter.optionTitle1, state: .normal)
        optionButton2.set(localizedStylableText: presenter.optionTitle2, state: .normal)
        optionButton1.titleLabel?.textAlignment = .center
        title = presenter.title 
    }
    
    private func setupButton(_ button: UIButton, _ isSelected: Bool) {
        let font = UIFont.latoBold(size: 16.0)
        let color = isSelected ? UIColor.sanGreyDark : .sanGreyMedium
        button.titleLabel?.font = font
        button.setTitleColor(color, for: .normal)
    }
    
    fileprivate func updateTopMenu() {
        let isPresentViewController1 = viewController1 != nil
        let isPresentViewController2 = viewController2 != nil
        topMenuView.isHidden = !(isPresentViewController1 && isPresentViewController2)
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        currentOptionIndicatorConstraint?.isActive = false
        currentOptionIndicatorConstraint = selectorView.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
        currentOptionIndicatorConstraint?.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.topMenuView.layoutIfNeeded()
        }

        if sender.tag == 0 {
            remove(viewController2)
            add(viewController1)
        } else {
            remove(viewController1)
            add(viewController2)
        }

        setupButton(optionButton1, sender.tag == optionButton1.tag)
        setupButton(optionButton2, sender.tag == optionButton2.tag)
    }

    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }

    // MARK: - Private

    private func add(_ viewController: UIViewController?) {
        guard let newView = viewController?.view else {
            return
        }
        newView.translatesAutoresizingMaskIntoConstraints = false

        addChild(viewController!)
        newView.frame = viewControllerContainer.frame
        viewControllerContainer.addSubview(newView)
        newView.embedInto(container: viewControllerContainer)
        viewController!.didMove(toParent: self)
        currentViewController = viewController
    }

    private func remove(_ viewController: UIViewController?) {
        viewController?.willMove(toParent: nil)
        viewController?.view.removeFromSuperview()
        viewController?.removeFromParent()
    }

}

extension DualContainerViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

