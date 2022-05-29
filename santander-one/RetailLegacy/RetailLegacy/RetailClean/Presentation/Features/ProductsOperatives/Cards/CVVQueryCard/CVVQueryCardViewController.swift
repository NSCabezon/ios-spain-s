import UIKit
import UI

protocol CVVQueryCardPresenterProtocol: Presenter {
    var cvvNumber: String? { get }
}

class CVVQueryCardViewController: BaseViewController <CVVQueryCardPresenterProtocol> {
    override class var storyboardName: String {
        return "CardsOperatives"
    }
    
    @IBOutlet weak var cvvLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardImageView: UIImageView!
    
    var screenStatusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    override func prepareView() {
        super.prepareView()
        backgroundView.backgroundColor = UIColor.sanGreyDark.withAlphaComponent(0.7)
        cvvLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoLight(size: 20), textAlignment: .left))
        cardImageView.image = Assets.image(named: "img_reverse_card")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCVVNumber()
        setAccessibilityIdentifiers()
    }
    
    func setupNavigationBarView() {
        guard let navigationBar = UINib(nibName: "NavigationBarView", bundle: .module).instantiate(withOwner: nil, options: nil)[0] as? NavigationBarView else {
            return
        }
        navigationBar.title = stringLoader.getString("toolbar_title_seeCvv")
        navigationBar.titleLabel.accessibilityIdentifier = "cvvQuery_navBarTitle"
        navigationBar.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        navigationBar.setup()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
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
    
    func setupCVVNumber() {
        guard let cvvNumber = presenter.cvvNumber else { return }
        cvvLabel.text = cvvNumber
    }
    
    private func setAccessibilityIdentifiers() {
        cvvLabel.accessibilityIdentifier = "cvvQuery_label"
        cardImageView.accessibilityIdentifier = "cvvQuery_image_card"
    }
}
