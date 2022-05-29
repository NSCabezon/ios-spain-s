//
//  CardSubscriptionsViewController.swift
//  Cards
//
//  Created by alvola on 01/03/2021.
//

import UIKit
import UI
import CoreFoundationLib

protocol CardWithSubscriptionsViewControllerProtocol: CardSubscriptionGlobalViewProtocol {

}

final class CardSubscriptionsViewController: UIViewController {

    @IBOutlet private weak var containerView: UIView!
    let presenter: CardSubscriptionPresenterProtocol
    
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(with: containerView)
        view.setScrollInsets(UIEdgeInsets(top: 11, left: 0.0, bottom: 11.0, right: 0.0))
        view.setSpacing(20.0)
        return view
    }()
    
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.textColor = .brownishGray
        label.font = UIFont.santander(size: 16.0)
        label.configureText(withLocalizedString: localized("m4m_label_payCardRegistered"))
        label.accessibilityIdentifier = "m4m_label_payCardRegistered"
        return label
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
    
    var isLoading = false {
        didSet {
            isLoading ? showLoading() : dismissLoading()
        }
    }
    
    private var inactiveSubscriptionsVisibles = false
    private var inactiveSubscriptionsViews = [CardWithSubscriptionsMainView]()
    private var separator: InactiveSubscriptionsView?

    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: CardSubscriptionPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var showCardSubscriptionFrom: ShowCardSubscriprionFromView {
        return .card
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
}

private extension CardSubscriptionsViewController {
    func setupNavigationBar() {
        NavigationBarBuilder(style: .white,
                             title: .title(key: "toolbar_title_m4m"))
        .setLeftAction(.back(action: #selector(didSelectBack)))
        .setRightActions(.menu(action: #selector(didSelectMenu)))
        .build(on: self, with: nil)
    }
    
    @objc func didSelectBack() {
        presenter.didSelectBack()
    }
    
    @objc func didSelectMenu() {
        presenter.didSelectMenu()
    }
    
    func configureView() {
        containerView.backgroundColor = .white
    }
    
    func clearView() {
        scrollableStackView.getArrangedSubviews().forEach {
            scrollableStackView.stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
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
    
    @objc func didSelectCardsHome() {
        presenter.didSelectCardsHome(sender: self)
    }
}

extension CardSubscriptionsViewController: CardWithSubscriptionsViewControllerProtocol {
    
    func showSubscriptionsMovements(_ model: [CardSubscriptionViewModel]) {
        clearView()
        setupSubscriptionsViewWithModel(model)
    }
    
    func showEmptyView(cause: EmptyViewCause) {
        setGotoCardsHomeButtonVisible(true)
        clearView()
        scrollableStackView.addArrangedSubview(topLabel)
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
        scrollableStackView.addArrangedSubview(empty)
    }
    
    func setupSubscriptionsViewWithModel(_ viewModel: [CardSubscriptionViewModel]) {
        let activeSubscriptions = viewModel.filter({$0.isActive == true})
        let inactiveSubscriptions = viewModel.filter({$0.isActive == false})
        
        if !activeSubscriptions.isEmpty {
            let view = CardWithSubscriptionsMainView()
            view.delegate = self
            view.configView(activeSubscriptions, type: .payments, numOfActiveShops: activeSubscriptions.count)
            scrollableStackView.addArrangedSubview(topLabel)
            scrollableStackView.addArrangedSubview(view)
        }

        guard inactiveSubscriptions.count > 0 else { return }
        addSeparatorWithSubscriptionsCount(inactiveSubscriptions.count)
        inactiveSubscriptionsViews.removeAll()
        inactiveSubscriptionsVisibles = activeSubscriptions.count == 0
        inactiveSubscriptions.forEach { (viewModel) in
            let view = CardWithSubscriptionsMainView()
            view.delegate = self
            view.configView(viewModel, type: .historic)
            view.isHidden = (activeSubscriptions.count == 0) ? false : true
            inactiveSubscriptionsViews.append(view)
            scrollableStackView.addArrangedSubview(view)
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
    
    @objc func separatorPressed() {
        inactiveSubscriptionsVisibles = !inactiveSubscriptionsVisibles
        separator?.isOpen(inactiveSubscriptionsVisibles)
        inactiveSubscriptionsViews.forEach({
            $0.isHidden = !inactiveSubscriptionsVisibles
        })
    }
    
    func showOptionsToUpdateSubscription(title: LocalizedStylableText, body: LocalizedStylableText, action: LocalizedStylableText, onActionable: @escaping (Bool) -> Void) {
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
                                              action: onAccept))),
            .margin(12.0)
        ]
        let builder = LisboaDialog(items: components, closeButtonAvailable: true)
        builder.showIn(self)
    }
}

extension CardSubscriptionsViewController: LoadingViewPresentationCapable {
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

extension CardSubscriptionsViewController: CardWithSubscriptionsMainViewDelegate {
    func didTapInDetail(_ viewModel: CardSubscriptionViewModel) {
        presenter.didSelectDetail(viewModel)
    }
    
    func didTapInPaymentsInDisabledShops() {
        presenter.didTapInPaymentsInDisabledShops()
    }
    
    func didSelectSeeFrationateOptions(_ viewModel: CardSubscriptionViewModel) {
        presenter.didSelectSeeFrationateOptions(viewModel)
    }
    
    func didTapInSubscriptionSwitch(_ isOn: Bool, viewModel: CardSubscriptionViewModel) {
        presenter.didTapInSubscriptionSwitch(isOn, viewModel: viewModel)
    }
}
