//
//  CardSubscriptionViewController.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 24/02/2021.
//

import UI
import CoreFoundationLib

enum EmptyViewCause {
    case nodata
    case error
}

protocol CardsSubscriptionViewControllerProtocol: CardSubscriptionGlobalViewProtocol {

}

protocol CardSubscriptionGlobalViewProtocol: OldDialogViewPresentationCapable {
    var presenter: CardSubscriptionPresenterProtocol { get }
    var showCardSubscriptionFrom: ShowCardSubscriprionFromView { get }
    func showEmptyView(cause: EmptyViewCause)
    func showLoadingView(_ completion: (() -> Void)?)
    func hideLoadingView()
    func showSubscriptionsMovements(_ model: [CardSubscriptionViewModel])
    func showOptionsToUpdateSubscription(title: LocalizedStylableText,
                                         body: LocalizedStylableText,
                                         action: LocalizedStylableText,
                                         onActionable: @escaping (Bool) -> Void)

}

final class CardsSubscriptionsViewController: UIViewController {
    var presenter: CardSubscriptionPresenterProtocol
    @IBOutlet private weak var topSeparatorView: UIView!
    @IBOutlet private weak var containerView: UIView!
    private var titleLabel: UILabel {
        let label = UILabel()
        label.textColor = .brownishGray
        label.configureText(withKey: "m4m_label_payCardRegistered",
                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16),
                                                                                 alignment: .left,
                                                                                 lineHeightMultiple: 0.75))
        label.numberOfLines = 2
        return label
    }
    private var separator: InactiveSubscriptionsView?
    private var inactiveSubscriptionsVisibles = false
    private var inactiveSubscriptionsViews = [SubscriptionMovementView]()
    
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(with: containerView)
        view.setScrollInsets(UIEdgeInsets(top: 16, left: 0.0, bottom: 16.0, right: 0.0))
        view.setSpacing(12.0)
        return view
    }()
    
    private lazy var cardsHomeButton: WhiteLisboaButton = {
        let button = WhiteLisboaButton()
        button.addAction {
            self.didSelectCardsHome()
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("m4m_button_goToCards"), for: .normal)
        button.configureAsWhiteButton()
        return button
    }()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: CardSubscriptionPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var showCardSubscriptionFrom: ShowCardSubscriprionFromView {
        return .general
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
}

extension CardsSubscriptionsViewController: CardsSubscriptionViewControllerProtocol {
    func showSubscriptionsMovements(_ model: [CardSubscriptionViewModel]) {
        clearView()
        setupSubscriptionsViewWithModel(model)
    }
    
    func showEmptyView(cause: EmptyViewCause) {
        setGotoCardsHomeButtonVisible(true)
        view.backgroundColor = .white
        clearView()
        let empty = CardSubscriptionsEmptyView()
        empty.heightAnchor.constraint(equalToConstant: 365).isActive = true
        switch cause {
        case .error:
            empty.updateTitle(localized("m4m_label_sorry"))
            empty.updateSubtitle(localized("m4m_label_pleaseTryAgain"))
        case .nodata:
            empty.updateTitle(localized("m4m_label_notPayments"))
            empty.updateSubtitle(localized("m4m_label_withoutNotPayments"))
        }
        scrollableStackView.addArrangedSubview(titleLabel)
        scrollableStackView.addArrangedSubview(empty)
    }
    
    func showOptionsToUpdateSubscription(title: LocalizedStylableText,
                                         body: LocalizedStylableText,
                                         action: LocalizedStylableText,
                                         onActionable: @escaping (Bool) -> Void) {
        let absoluteMargin: (left: CGFloat, right: CGFloat) = (left: 19.0, right: 9.0)
        let onCancel: () -> Void = { onActionable(false) }
        let onAccept: () -> Void = { onActionable(true) }
        let components: [LisboaDialogItem] = [
            .margin(11.0),
            .styledText(
                LisboaDialogTextItem(
                    text: title,
                    font: .santander(family: .text, type: .regular, size: 29),
                    color: .black,
                    alignament: .center,
                    margins: absoluteMargin)),
            .margin(5.0),
            .styledText(
                LisboaDialogTextItem(
                    text: body,
                    font: .santander(family: .text, type: .light, size: 16),
                    color: .lisboaGray,
                    alignament: .center,
                    margins: absoluteMargin)),
            .margin(26.0),
            .horizontalActions(
                HorizontalLisboaDialogActions(
                    left: LisboaDialogAction(title: localized("generic_link_no"),
                                             type: .white,
                                             margins: absoluteMargin,
                                             action: onCancel),
                    right: LisboaDialogAction(title: action,
                                              type: .red,
                                              margins: absoluteMargin,
                                              action: onAccept ))),
            .margin(12.0)
        ]
        let builder = LisboaDialog(items: components, closeButtonAvailable: true)
        builder.showIn(self)
    }
}

extension CardsSubscriptionsViewController: LoadingViewPresentationCapable {
    public var associatedLoadingView: UIViewController {
        return self
    }
    
    func showLoadingView(_ completion: (() -> Void)?) {
        self.showLoading(completion: completion)
    }
    
    func hideLoadingView() {
        self.dismissLoading()
    }
}

// MARK: - Private methods
private extension CardsSubscriptionsViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(style: .white,
                                           title: .title(key: "toolbar_title_m4m"))
        .setLeftAction(NavigationBarBuilder.LeftAction.back(action: #selector(didSelectBack)))
        .setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: nil)
    }
    
    func setupView() {
        scrollableStackView.setScrollDelegate(self)
        topSeparatorView.backgroundColor = .lightSkyBlue
        containerView.backgroundColor = .clear
        view.backgroundColor = .skyGray
    }
    
    func setupSubscriptionsViewWithModel(_ viewModel: [CardSubscriptionViewModel]) {
        let activeSubscriptions = viewModel.filter({$0.isActive == true})
        let inactiveSubscriptions = viewModel.filter({$0.isActive == false})
        scrollableStackView.addArrangedSubview(titleLabel)
        activeSubscriptions.forEach { (viewModel) in
            let view = setSubscriptionMovementView(viewModel, type: .payments)
            scrollableStackView.addArrangedSubview(view)
        }
        
        guard inactiveSubscriptions.count > 0 else { return }
        addSeparatorWithSubscriptionsCount(inactiveSubscriptions.count)
        inactiveSubscriptionsViews.removeAll()
        inactiveSubscriptionsVisibles = activeSubscriptions.count == 0
            
        inactiveSubscriptions.forEach { (viewModel) in
            let view = setSubscriptionMovementView(viewModel, type: .historic)
            view.isHidden = (activeSubscriptions.count == 0) ? false : true
            inactiveSubscriptionsViews.append(view)
            scrollableStackView.addArrangedSubview(view)
        }
    }
    
    func setSubscriptionMovementView(_ viewModel: CardSubscriptionViewModel, type: CardSubscriptionSeeMoreType) -> SubscriptionMovementView {
        let view = SubscriptionMovementView()
        view.delegate = self
        view.configView(viewModel, type: type, fromViewType: .general)
        return view
    }
    
    func clearView() {
        scrollableStackView.getArrangedSubviews().forEach {
            scrollableStackView.stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    func addSeparatorWithSubscriptionsCount(_ count: Int) {
        let view = InactiveSubscriptionsView(frame: .zero)
        view.updateAmountIndicatorWith(count)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(separatorPressed)))
        view.isUserInteractionEnabled = true
        scrollableStackView.addArrangedSubview(view)
        separator = view
    }
    
    func setGotoCardsHomeButtonVisible(_ visibility: Bool) {
        if visibility {
            view.addSubview(cardsHomeButton)
            cardsHomeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                          constant: 28.0).isActive = true
            view.trailingAnchor.constraint(equalTo: cardsHomeButton.trailingAnchor,
                                                           constant: 28.0).isActive = true
            cardsHomeButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            
            if #available(iOS 11.0, *) {
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: cardsHomeButton.bottomAnchor,
                                                                 constant: 22).isActive = true
            } else {
                view.bottomAnchor.constraint(equalTo: cardsHomeButton.bottomAnchor,
                                             constant: 22).isActive = true
            }
        }
    }
    
    @objc func didSelectBack() {
        presenter.didSelectBack()
    }
    
    @objc func openMenu() {
        presenter.didSelectMenu()
    }
    
    @objc func separatorPressed() {
        inactiveSubscriptionsVisibles = !inactiveSubscriptionsVisibles
        separator?.isOpen(inactiveSubscriptionsVisibles)
        inactiveSubscriptionsViews.forEach({
            $0.isHidden = !inactiveSubscriptionsVisibles
        })
    }
    
    @objc func didSelectCardsHome() {
        presenter.didSelectCardsHome(sender: self)
    }
}

extension CardsSubscriptionsViewController: UIScrollViewDelegate {}

extension CardsSubscriptionsViewController: SubscriptionMovementViewDelegate {
    func didTapInDetail(_ viewModel: CardSubscriptionViewModel) {
        presenter.didSelectDetail(viewModel)
    }
    
    func didSelectSeeFrationateOptions(_ viewModel: CardSubscriptionViewModel) {
        presenter.didSelectSeeFrationateOptions(viewModel)
    }
    
    func didTapInSubscriptionSwitch(_ isOn: Bool, viewModel: CardSubscriptionViewModel) {
        presenter.didTapInSubscriptionSwitch(isOn, viewModel: viewModel)
    }
}
