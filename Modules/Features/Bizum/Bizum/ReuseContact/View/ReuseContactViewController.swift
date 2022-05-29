import UI
import CoreFoundationLib
import ESUI

protocol ReuseContactViewProtocol: class {
    func updateView(_ viewModel: [ReuseContactItemsViewModel])
    func showFeatureNotAvailableToast()
}

final class ReuseContactViewController: UIViewController {
    private let presenter: ReuseContactPresenterProtocol
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var reuseContainerView: UIView! {
        didSet {
            self.reuseContainerView.layer.cornerRadius = 10
            self.reuseContainerView.layer.masksToBounds = false
            self.reuseContainerView.layer.borderColor = UIColor.lisboaGray.cgColor
            self.applyCommonShadow(reuseContainerView)
            self.disableDinamicShadowCalculation(reuseContainerView, cornerRadius: 10)
        }
    }
    @IBOutlet weak var reuseContainerAboveView: UIView!
    @IBOutlet weak var roundView: UIView! {
        didSet {
            let cornerRadius = roundView.frame.width / 2
            self.roundView.layer.cornerRadius = cornerRadius
            self.roundView.layer.masksToBounds = false
            self.roundView.layer.borderColor = UIColor.lisboaGray.cgColor
            self.applyCommonShadow(roundView)
            self.disableDinamicShadowCalculation(roundView, cornerRadius: cornerRadius)
        }
    }
    @IBOutlet weak var insideCircle: UIView!
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            let image = Assets.image(named: "icnCloseGray")?.withRenderingMode(.alwaysTemplate)
            self.closeButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
            self.closeButton.setImage(image, for: .normal)
            self.closeButton.tintColor = .brownGray
        }
    }
    @IBOutlet weak var stackView: UIStackView!

    init(presenter: ReuseContactPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "ReuseContactViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.presenter.viewDidLoad()
        self.configureView()
    }
}

extension ReuseContactViewController: ReuseContactViewProtocol {
    func updateView(_ viewModel: [ReuseContactItemsViewModel]) {
        viewModel.forEach { item in
            switch item {
            case .initials(let item):
                let view = BizumInitialsView()
                view.configureView(with: item)
                insideCircle.addSubview(view)
                view.fullFit()
            case .simple(let item):
                let view = ReuseSimpleContactItemView()
                view.update(with: item)
                self.stackView.addArrangedSubview(view)
            case .multiple(let item):
                self.addMultipleHeaderView()
                self.addMultipleView(item)
            case .options(let items):
                self.setOptions(items)
            }
        }
    }

    func showFeatureNotAvailableToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}

extension ReuseContactViewController: BizumHomeOptionViewDelegate {
    func didSelectOption(_ option: BizumHomeOptionViewModel?) {
        self.presenter.didSelectOption(option)
    }
}
private extension ReuseContactViewController {
    @objc func dismissViewController() {
        self.presenter.didSelectDismiss()
    }

    func configureView() {
        if #available(iOS 11.0, *) {
            self.reuseContainerAboveView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.reuseContainerAboveView.layer.cornerRadius = 10
            self.reuseContainerAboveView.layer.masksToBounds = false
        } else {
            self.reuseContainerAboveView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        self.backgroundView.backgroundColor = .clear
        self.backgroundView.addGestureRecognizer(tapGesture)
    }

    func applyCommonShadow(_ view: UIView) {
        view.layer.shadowColor = UIColor.lisboaGray.withAlphaComponent(0.9).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
    }
    
    func disableDinamicShadowCalculation(_ view: UIView, cornerRadius: CGFloat) {
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: cornerRadius).cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }

    func setOptions(_ items: [BizumHomeOptionViewModel]) {
        for item in items {
            let view = BizumHomeOptionView()
            view.set(item)
            view.delegate = self
            self.stackView.addArrangedSubview(view)
        }
    }

    func addMultipleView(_ item: ReuseMultipleContactViewModel) {
        let view = ReuseMultipleContactItemView()
        view.update(item)
        self.stackView.addArrangedSubview(view)
    }

    func addMultipleHeaderView() {
        let imageView = UIImageView(image: ESAssets.image(named: "icnMultiple"))
        self.insideCircle.addSubview(imageView)
        self.insideCircle.accessibilityIdentifier = AccessibilityBizumReuseContact.icnMultiple
        imageView.fullFit()
    }
}
