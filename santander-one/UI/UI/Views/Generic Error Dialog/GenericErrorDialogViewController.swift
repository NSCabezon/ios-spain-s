import UIKit
import CoreFoundationLib

protocol GenericErrorDialogViewProtocol: AnyObject {
    func showWithViewModel(_ viewModel: GenericErrorDialogViewModel)
}

class GenericErrorDialogViewController: UIViewController {
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var actionsTitleLabel: UILabel!
    @IBOutlet private weak var actionsStackView: UIStackView!
    @IBOutlet private weak var scrollHeight: NSLayoutConstraint!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var actionsContainerView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var closeContainerView: UIView!
    @IBOutlet weak var separatorTitleView: UIView!
    
    let presenter: GenericErrorDialogPresenterProtocol
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: GenericErrorDialogPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollHeight.constant = self.scrollView.contentSize.height
    }
    
    // MARK: - Objc methods
    
    @objc private func didSelectClose() {
        self.presenter.dismiss()
    }
}

extension GenericErrorDialogViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            self.closeContainerView.addShadow(location: .bottom, opacity: 0.3, height: 1.0)
        } else {
            self.closeContainerView.removeShadow()
        }
    }
}

private extension GenericErrorDialogViewController {
    
    func setup() {
        self.view.backgroundColor = UIColor.lisboaGray.withAlphaComponent(0.7)
        self.containerView.layer.cornerRadius = 5.0
        self.containerView.layer.masksToBounds = true
        self.actionsContainerView.backgroundColor = .blueAnthracita
        self.imageView.image = Assets.image(named: "icnAlert")
        self.closeButton.tintColor = .santanderRed
        self.closeButton.setImage(Assets.image(named: "icnClose"), for: .normal)
        self.closeButton.addTarget(self, action: #selector(didSelectClose), for: .touchUpInside)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.font = .santander(family: .headline, type: .regular, size: 29)
        self.titleLabel.configureText(withLocalizedString: localized("generic_error_alert_title"))
        self.descriptionLabel.textColor = .lisboaGray
        self.descriptionLabel.font = .santander(family: .text, type: .regular, size: 16)
        let configuration = LocalizedStylableTextConfiguration(lineHeightMultiple: 0.8)
        self.descriptionLabel.configureText(withLocalizedString: localized("generic_error_alert_text"),
                                            andConfiguration: configuration)
        self.actionsTitleLabel.configureText(withLocalizedString: localized("generic_error_title_options"))
        self.actionsTitleLabel.font = .santander(family: .text, type: .bold, size: 20)
        self.actionsTitleLabel.textColor = .white
        self.scrollView.delegate = self
        self.closeContainerView.superview?.bringSubviewToFront(self.closeContainerView)
        self.separatorTitleView.backgroundColor = UIColor.mediumSkyGray
    }
}

extension GenericErrorDialogViewController: GenericErrorDialogViewProtocol {
    
    func showWithViewModel(_ viewModel: GenericErrorDialogViewModel) {
        viewModel.actions.forEach { action in
            let view = GenericErrorDialogActionView()
            view.setupWithViewModel(action)
            self.actionsStackView.addArrangedSubview(view)
        }
    }
}
