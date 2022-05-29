import UI
import CoreFoundationLib
import ESUI

protocol BizumDetailViewProtocol: class, LoadingViewPresentationCapable {
    func showDetail(_ items: [BizumDetailItemsViewModel])
    func showMultimedia(_ viewModels: [MultimediaType])
    func showFeatureNotAvailableToast()
    func didTapShare(_ viewModel: ShareBizumDetailViewModel)
}

final class BizumDetailViewController: UIViewController {
    let presenter: BizumDetailPresenterProtocol
    private var multimediaContainerView: MultimediaContainerView?
    private var receiverDetailView: ReceiverDetailViewContainer?
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var borderedView: UIView! {
        didSet {
            self.borderedView.drawBorder(cornerRadius: 0, color: .mediumSkyGray, width: 1)
        }
    }
    @IBOutlet private weak var tornView: UIView!
    @IBOutlet private weak var tornImageView: UIImageView! {
        didSet {
            self.tornImageView.contentMode = .scaleToFill
            self.tornImageView.image = Assets.image(named: "imgTornBig")
        }
    }
    @IBOutlet private weak var openCloseButton: UIButton! {
        didSet {
            self.openCloseButton.setBackgroundImage(Assets.image(named: "icnOvalArrowDown"), for: .normal)
            self.openCloseButton.setBackgroundImage(Assets.image(named: "icnOvalArrowUp"), for: .selected)
            self.openCloseButton.addTarget(self, action: #selector(didTapOnOpenCloseButton), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var openCloseButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var actionsStackView: UIStackView!
    @IBOutlet private weak var actionsStackViewTopConstraint: NSLayoutConstraint!

    // MARK: - UIInterfaceOrientationMask
    /// shouldAutorotate isn't needed

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    init(presenter: BizumDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "BizumDetailViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        builder.build(on: self, with: presenter)
    }

    @objc func didSelectDismiss() {
        self.presenter.didSelectDismiss()
    }
}

private extension BizumDetailViewController {
    @objc func didTapOnOpenCloseButton() {
        if self.openCloseButton.isSelected {
            self.collapse()
        } else {
            self.expand()
        }
        self.openCloseButton.isSelected = !self.openCloseButton.isSelected
    }
}

extension BizumDetailViewController: BizumDetailViewProtocol {
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
            case .actions(let items):
                self.addActions(items)
            }
        }
    }

    func showMultimedia(_ viewModels: [MultimediaType]) {
        self.multimediaContainerView?.updateView(viewModels)
    }
    
    func showFeatureNotAvailableToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }

    // MARK: - ShareBizumView
    /// The modalPresentationStyle is overCurrentContext because avoid screen rotation
    func didTapShare(_ viewModel: ShareBizumDetailViewModel) {
        let shareHandler = SharedHandler()
        let shareView = ShareBizumView()
        shareView.modalPresentationStyle = .overCurrentContext
        shareView.loadViewIfNeeded()
        shareView.setInfoFromDetail(viewModel)
        shareHandler.shareByImage(shareView, in: self, viewToShare: shareView.containerView, onlyWhatsApp: false)
    }
}

private extension BizumDetailViewController {
    
    func configActionsStackView(numberOfActions: Int) {
        actionsStackView.spacing = 8
        actionsStackView.alignment = .center
        if numberOfActions > 1 {
            actionsStackView.axis = .horizontal            
            actionsStackView.distribution = .fillEqually
        } else {
            actionsStackView.axis = .vertical
        }
    }
    
    func addActions(_ items: [BizumActionType]) {
        configActionsStackView(numberOfActions: items.count)
        items.forEach { addActionView($0) }
    }
    
    func addActionView(_ item: BizumActionType) {
        let actionView = BizumActionView(type: item)
        actionView.delegate = self
        actionView.translatesAutoresizingMaskIntoConstraints = false
        actionView.widthAnchor.constraint(greaterThanOrEqualToConstant: 163).isActive = true
        actionView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        actionsStackView.addArrangedSubview(actionView)
    }

    func addRecipients(_ recipients: [ReceiverDetailViewModel], title: TextWithAccessibility) {
        let containerView = ReceiverDetailViewContainer(recipients, title: title)
        self.receiverDetailView = containerView
        self.stackView.addArrangedSubview(containerView)
        if recipients.count == 1 {
            self.showOneReceipt()
            actionsStackViewTopConstraint.constant = -7
        } else {
            actionsStackViewTopConstraint.constant = 15
            self.collapse()
        }
    }

    func collapse() {
        self.tornImageView.isHidden = false
        openCloseButtonBottomConstraint.constant = 0
        self.receiverDetailView?.collapse()
    }

    func showOneReceipt() {
        self.tornView.isHidden = true
    }

    func expand() {
        self.tornImageView.isHidden = true
        openCloseButtonBottomConstraint.constant = 10
        self.receiverDetailView?.expand()
    }
}

extension BizumDetailViewController: MultimediaContainerViewDelegate {
    func showImage() {
        self.presenter.showImage()
    }
}

extension BizumDetailViewController: BizumActionViewDelegate {
    func didTap(_ actionButton: BizumActionView, type: BizumActionType) {
        presenter.actionDidTap(type: type)
    }
}
