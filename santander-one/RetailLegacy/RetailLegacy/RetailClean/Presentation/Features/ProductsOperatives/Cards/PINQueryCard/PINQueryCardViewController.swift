import UIKit
import CoreFoundationLib

protocol PINQueryCardPresenterProtocol: Presenter {
     var pinNumber: String? { get }
}

class PINQueryCardViewController: BaseViewController <PINQueryCardPresenterProtocol> {
    override class var storyboardName: String {
        return "CardsOperatives"
    }
    
    @IBOutlet weak var titleLabel: UILabel!    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var stackPinNumberView: UIStackView!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var screenStatusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    override func prepareView() {
        super.prepareView()
        backgroundView.backgroundColor = UIColor.sanGreyDark.withAlphaComponent(0.7)
        titleLabel.set(localizedStylableText: stringLoader.getString("toolbar_title_pinCode"))
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoRegular(size: 20), textAlignment: .left))
        separatorView.backgroundColor = .sanRed
        modalView.drawBorder(cornerRadius: 5.0, color: .lisboaGray)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPinNumber()
        setAccessibilityIdentifiers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func setupNavigationBarView() {
        guard let navigationBar = UINib(nibName: "NavigationBarView", bundle: .module).instantiate(withOwner: nil, options: nil)[0] as? NavigationBarView else {
            return
        }
        navigationBar.title = stringLoader.getString("toolbar_title_seePin")
        navigationBar.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        navigationBar.setup()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.titleLabel.accessibilityIdentifier = "pinQuery_navBarTitle"
        navigationBarView.addSubview(navigationBar)
        navigationBarView.topAnchor.constraint(equalTo: navigationBar.topAnchor).isActive = true
        navigationBarView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
        navigationBarView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor).isActive = true
        navigationBarView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor).isActive = true
        heightConstraint.constant = navigationBar.frame.size.height + screenStatusBarHeight
        navigationBarView.backgroundColor = UIColor.white
        navigationBarView.layoutIfNeeded()
    }
    
    @objc func close() {
        self.modalTransitionStyle = .crossDissolve
        self.dismiss(animated: false, completion: nil)
    }
    
    func closeWithAnimation() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.close()
        }
    }
    
    func setupPinNumber() {
        guard let pinNumber = presenter.pinNumber else { return }
        let pinNumberArray = Array(pinNumber)
     
        for number in pinNumberArray {
            guard let pinNumberView = UINib(nibName: "PINNumberView", bundle: .module).instantiate(withOwner: nil, options: nil)[0] as? PINNumberView else { return }
            pinNumberView.setup()
            pinNumberView.numberLabel.text = number.description
            pinNumberView.accessibilityIdentifier = "pinQuery_number"
            stackPinNumberView.addArrangedSubview(pinNumberView)
        }
    }
    
    private func setAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = "pinQuery_title"
    }
    
    private func setAccessibilityInfo() {
        guard let pinNumber = presenter.pinNumber else { return }
        let pinCode = pinNumber.map { "\($0)" }.joined(separator: " ")
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
        UIAccessibility.post(notification: .announcement, argument: pinCode)
    }
}

extension PINQueryCardViewController: AccessibilityCapable {}
