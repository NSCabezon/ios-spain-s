import UI
import UIKit
import CoreFoundationLib

protocol WithholdingViewProtocol: AnyObject {
    func didLoadWithholding(_ viewModel: [WithholdingViewModel])
    func didErrorWithholding()
    func showTotalAmount(_ viewModel: WithholdingAmountViewModel)
    func showItemsView(_ viewModel: [WithholdingViewModel])
    func showLoadingView()
    func showEmptyView()
    func showErrorView()
}

class WithholdingViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var withholdingImage: UIImageView!
    @IBOutlet weak var withholdingLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var backgroundView: UIView!
    
    var withholdings: [WithholdingViewModel] = []
    let presenter: WithholdingPresenterProtocol
    
    // Views
    private var loadingView: WithholdingLoadingView = WithholdingLoadingView()
    private var emptyView: WithholdingEmptyView = WithholdingEmptyView()
    private var messageView: WithholdingMessageView = WithholdingMessageView()
    private var errorView: WithholdingEmptyView = WithholdingEmptyView()
    private let headerHeight: CGFloat = 76 // 86 header - 5 top - 5 botton
    private let maxHeighToBorders: CGFloat = 200
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: WithholdingPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateViewOnAppear()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        presenter.didSelectDismiss()
    }
    
    private func setupView() {
        heightViewConstraint.constant = 0
        backgroundView.backgroundColor = .lisboaGray
        setupHeader()
        addGesture()
        contentView.drawRoundedAndShadowedNew()
        createViews()
        self.setAccessibilityIdentifiers()
    }
    
    private func setupHeader() {
        closeButton.setImage(Assets.image(named: "icnClose"), for: .normal)
        closeButton.tintColor = .santanderRed
        withholdingImage.image = Assets.image(named: "icnRetentions")
        withholdingLabel.text = localized("account_title_withholding")
        withholdingLabel.font = .santander(family: .text, type: .regular, size: 24.0)
        withholdingLabel.textColor = .black
        totalLabel.text = localized("summary_item_total")
        totalLabel.font = .santander(family: .text, type: .regular, size: 16.0)
        totalLabel.textColor = .grafite
        amountLabel.font = .santander(family: .text, type: .bold, size: 18.0)
        amountLabel.textColor = .darkTorquoise
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectDismiss))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    private func calculateHeight() -> CGFloat {
        let height = scrollView.subviews.map { $0.frame.size.height }.reduce(0, +)
        return headerHeight + height
    }
    
    private func updateHeight() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        let heightMax = min(calculateHeight(), view.frame.height - maxHeighToBorders)
        heightViewConstraint.constant = heightMax
    }
}

private extension WithholdingViewController {
    func animateViewOnAppear() {
        UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: .allowUserInteraction, animations: { [weak self] in
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self?.backgroundView.alpha = 0.6
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self?.contentView.alpha = 1
            }
        }, completion: nil)
    }
    
    func setAccessibilityIdentifiers() {
        self.closeButton.accessibilityIdentifier = AccessibilityWithholdingView.btnCloseModal
        self.closeButton.imageView?.accessibilityIdentifier = AccessibilityWithholdingView.icnCloseModal
        self.withholdingImage.accessibilityIdentifier = AccessibilityWithholdingView.icnRetentions
        self.withholdingLabel.accessibilityIdentifier = AccessibilityWithholdingView.tooltipTitleWithholding
        self.totalLabel.accessibilityIdentifier = AccessibilityWithholdingView.withholdingLabelTotal
        self.amountLabel.accessibilityIdentifier = AccessibilityWithholdingView.withholdingHeaderLabelAmount
        self.loadingView.setAccessibilityIdentifiers(imgAccessibilityID: AccessibilityWithholdingView.imgLoadingTransactionsLoading, labelAccessibilityID: AccessibilityWithholdingView.loadingLabelTransactionsLoading)
        self.emptyView.setAccessibilityIdentifiers(imgAccessibilityID: AccessibilityWithholdingView.imgLeaves, labelAccessibilityID: AccessibilityWithholdingView.withholdingLabelEmpty)
        self.errorView.setAccessibilityIdentifiers(imgAccessibilityID: AccessibilityWithholdingView.imgLeaves, labelAccessibilityID: AccessibilityWithholdingView.productTitleEmptyError, descriptionLabelAccessibilityID: AccessibilityWithholdingView.productLabelEmptyError)
        self.messageView.setAccessibilityIdentifiers(labelAccessibilityID: AccessibilityWithholdingView.tooltipLabelWithholding)
    }
}

extension WithholdingViewController: WithholdingViewProtocol {
    func showItemsView(_ viewModel: [WithholdingViewModel]) {
        stopLoading()
        viewModel.forEach {
            stackView.addArrangedSubview(WithholdingView($0))
        }
        stackView.addArrangedSubview(messageView)
        updateHeight()
    }
    
    func showEmptyView() {
        stopLoading()
        stackView.addArrangedSubview(emptyView)
        stackView.addArrangedSubview(messageView)
        updateHeight()
    }
    
    func showErrorView() {
        stopLoading()
        stackView.addArrangedSubview(errorView)
        stackView.addArrangedSubview(messageView)
        updateHeight()
    }
    
    func showLoadingView() {
        stackView.addArrangedSubview(loadingView)
        stackView.addArrangedSubview(messageView)
        updateHeight()
    }
    
    func didLoadWithholding(_ viewModel: [WithholdingViewModel]) {
        showItemsView(viewModel)
    }
    
    func didErrorWithholding() {
        showErrorView()
    }
    
    func showTotalAmount(_ viewModel: WithholdingAmountViewModel) {
        amountLabel.attributedText = viewModel.getAmountFormatted(font: .santander(family: .text, type: .bold, size: 20))
    }
    
    @objc private func didSelectDismiss() {
        presenter.didSelectDismiss()
    }
    
    private func stopLoading() {
        loadingView.stopAnimation()
        removeStackSubviews()
    }
    
    private func createViews() {
        let emptyViewText: LocalizedStylableText = localized("withholding_label_empty")
        let emptyViewModel = WithholdingEmptyViewModel(title: emptyViewText, descriptionTitle: LocalizedStylableText.empty, imageName: "imgLeaves")
        emptyView = WithholdingEmptyView(emptyViewModel)
        
        let errorViewTitle: LocalizedStylableText = localized("product_title_emptyError")
        let errorViewDescription: LocalizedStylableText = localized("product_label_emptyError")
        let errorViewModel = WithholdingEmptyViewModel(title: errorViewTitle, descriptionTitle: errorViewDescription, imageName: "imgLeaves")
        errorView = WithholdingEmptyView(errorViewModel)
        
        let loadingViewModel = WithholdingLoadingViewModel(title: localized("loading_label_transactionsLoading"))
        loadingView = WithholdingLoadingView(loadingViewModel)
        
        let messageViewModel = WithholdingMessageViewModel(title: localized("tooltip_label_withholding"))
        messageView = WithholdingMessageView(messageViewModel)
    }
    
    private func removeStackSubviews() {
        for view in self.stackView.arrangedSubviews {
            self.stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

extension WithholdingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: view)
        return !contentView.frame.contains(point)
    }
}
