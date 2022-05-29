import UIKit
import UI
import CoreFoundationLib
import ESUI

protocol BizumDetailMultipleViewProtocol: class, LoadingViewPresentationCapable {
    func showDetail(_ items: [BizumDetailItemsViewModel])
    func showMultimedia(_ viewModels: [MultimediaType])
}

class BizumDetailMultipleViewController: UIViewController {
    let presenter: BizumDetailMultiplePresenterProtocol
    private var multimediaContainerView: MultimediaContainerView?
    private var receiverDetailView: ReceiverDetailViewContainer?
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var borderedView: UIView! {
        didSet {
            self.borderedView.drawBorder(cornerRadius: 0, color: .mediumSkyGray, width: 1)
        }
    }
    @IBOutlet weak var multipleImageView: UIImageView! {
        didSet {
            self.multipleImageView.image = ESAssets.image(named: "icnMultiple")
        }
    }
    @IBOutlet weak var multipleDescriptionLabel: UILabel! {
        didSet {
            let configuration = LocalizedStylableTextConfiguration(
                font: .santander(family: .text, type: .regular, size: 14),
                lineBreakMode: .byWordWrapping
            )
            self.multipleDescriptionLabel.configureText(
                withKey: "bizumDetail_disclaimer_multiple",
                andConfiguration: configuration
            )
            self.multipleDescriptionLabel.textColor = .lisboaGray
            self.multipleDescriptionLabel.accessibilityIdentifier = AccessibilityBizumDetail.bizumDetailMultipleDescriptionLabel
        }
    }
    
    init(presenter: BizumDetailMultiplePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "BizumDetailMultipleViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIInterfaceOrientationMask
    /// shouldAutorotate isn't needed

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
}

extension BizumDetailMultipleViewController: BizumDetailMultipleViewProtocol {
    func showDetail(_ items: [BizumDetailItemsViewModel]) {
        items.forEach { (detailItem) in
            switch detailItem {
            case .amount(let item):
                let view = ItemDetailAmountView()
                item.setup(view)
                self.stackView.addArrangedSubview(view)
            case .origin(let item):
                let view = ItemDetailView()
                item.setup(view)
                self.stackView.addArrangedSubview(view)
            case .transferType(let item):
                let view = ItemDetailView()
                item.setup(view)
                self.stackView.addArrangedSubview(view)
            case .multimedia:
                let view = MultimediaContainerView()
                self.multimediaContainerView = view
                self.multimediaContainerView?.delegate = self
                self.stackView.addArrangedSubview(view)
            case .recipients(let items, let title):
                self.addRecipients(items, title: title)
            default:
                break
            }
        }
    }

    func showMultimedia(_ viewModels: [MultimediaType]) {
        self.multimediaContainerView?.updateView(viewModels)
    }
    
    func showFeatureNotAvailableToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}

private extension BizumDetailMultipleViewController {
    func configureView() {
        self.view.backgroundColor = UIColor.skyGray
    }

    func setupNavigationBar() {
        let titleImage = TitleImage(image: ESAssets.image(named: "icnBizumHeader"),
                                    topMargin: 4,
                                    width: 16,
                                    height: 16)
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithImage(key: "genericToolbar_title_detail", image: titleImage)
        )
        builder.setRightActions(.close(action: #selector(didSelectDismiss)))
        builder.build(on: self, with: self.presenter)
    }

    @objc func didSelectDismiss() {
        self.presenter.didSelectDismiss()
    }
    
    func addRecipients(_ recipients: [ReceiverDetailViewModel], title: TextWithAccessibility) {
        let containerView = ReceiverDetailViewContainer(recipients, title: title)
        self.receiverDetailView = containerView
        self.stackView.addArrangedSubview(containerView)
    }
    
}

extension BizumDetailMultipleViewController: MultimediaContainerViewDelegate {
    func showImage() {
        self.presenter.showImage()
    }
}
