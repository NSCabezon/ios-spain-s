import UIKit
import UI
import CoreFoundationLib

protocol FractionatedPaymentsViewProtocol: AnyObject, LoadingViewPresentationCapable, OldDialogViewPresentationCapable {
    func showFractionatedPayments(_ models: [FractionedPaymentsViewModel])
    func showEmptyView()
    func showSeeMoreCardsView()
    func showErrorView(_ error: String)
}

extension FractionedPaymentsViewController: LoadingViewPresentationCapable {}

final class FractionedPaymentsViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var headerView: UIView!

    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setSpacing(0)
        view.setup(with: self.containerView)
        return view
    }()
    
    private let presenter: FractionedPaymentsPresenterProtocol

    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: FractionedPaymentsPresenterProtocol) {
        self.presenter = presenter
        super.init(
            nibName: nibNameOrNil,
            bundle: nibBundleOrNil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
}

private extension FractionedPaymentsViewController {
    func setupView() {
        view.backgroundColor = .white
    }
    
    // MARK: NavigationBar
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .title(key: "toolbar_title_installmentPayments")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(
            on: self,
            with: self.presenter
        )
    }
    
    @objc func openMenu() {
        presenter.didSelectMenu()
    }
    
    @objc func dismissViewController() {
        presenter.didSelectDismiss()
    }
    
    // MARK: FractionedPayments views
    func addEmptyView() {
        let view = FractionedPaymentsEmptyView()
        view.configView(
            titleText: localized("financing_title_emptyCards"),
            descriptionText: "financing_text_emptyCards"
        )
        scrollableStackView.addArrangedSubview(view)
    }
    
    func addContentView(_ fractionatedPayments: [FractionedPaymentsViewModel]) {
        fractionatedPayments.forEach { item in
            let view = FractionedPaymentsView()
            view.configView(
                model: item,
                delegate: self
            )
            scrollableStackView.addArrangedSubview(view)
        }
    }
    
    func addSeeMoreCardsView() {
        let view = FractionedPaymentsSeeMoreCardsView()
        view.setDelegate(delegate: self)
        scrollableStackView.addArrangedSubview(view)
    }
    
    func removeArrangedSubviewsIfNeeded() {
        if !scrollableStackView.stackView.arrangedSubviews.isEmpty {
            scrollableStackView.stackView.removeAllArrangedSubviews()
        }
    }
}

extension FractionedPaymentsViewController: FractionatedPaymentsViewProtocol {
    func showEmptyView() {
        removeArrangedSubviewsIfNeeded()
        addEmptyView()
    }
    
    func showFractionatedPayments(_ models: [FractionedPaymentsViewModel]) {
        removeArrangedSubviewsIfNeeded()
        guard !models.isEmpty else {
            addEmptyView()
            return
        }
        addContentView(models)
    }
    
    func showSeeMoreCardsView() {
        addSeeMoreCardsView()
    }
    
    func showErrorView(_ error: String) {
        let action = Dialog.Action(title: localized("generic_button_accept"), style: .red) {
            self.dismiss(animated: true)
        }
        let localizedStylableText = LocalizedStylableText(text: error, styles: nil)
        let localizedStylableConfig = LocalizedStylableTextConfiguration(alignment: .center)
        let item = Dialog.Item.styledConfiguredText(
            localizedStylableText,
            configuration: localizedStylableConfig,
            identifier: nil
        )

        let dialog = Dialog(
            title: nil,
            items: [item],
            image: nil,
            actionButton: action,
            isCloseButtonAvailable: false
        )
        dialog.show(in: self)
    }
}

extension FractionedPaymentsViewController: FractionedPaymentsViewDelegate {
    func didSelectFractionedPaymentMovement(_ viewModel: FractionablePurchaseViewModel) {
        presenter.didSelectFractionedPaymentMovement(viewModel)
    }
    
    func didSelectSeeFrationateOptions(_ viewModel: FractionablePurchaseViewModel) {
        presenter.didSelectSeeFrationateOptions(viewModel)
    }
}

extension FractionedPaymentsViewController: FractionedPaymentsSeeMoreCardsViewDelegate {
    func didTapInSeeMoreCards() {
        presenter.didSelectInSeeMoreCards()
    }
}
