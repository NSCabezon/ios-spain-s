//
//  CardsSuscriptionsDetailViewController.swift
//  Cards
//
//  Created by Ignacio González Miró on 7/4/21.
//

import UIKit
import CoreFoundationLib
import UI

protocol CardSubscriptionsDetailViewProtocol: OldDialogViewPresentationCapable {
    func configCardSubscriptionDetailView(_ viewModel: CardSubscriptionViewModel)
    func updateCardSubscriptionDetailView(_ viewModel: CardSubscriptionViewModel)
    func updateHistoricView(_ viewModels: [CardSubscriptionDetailHistoricViewModel], isOpen: Bool?)
    func showLoadingView(_ completion: (() -> Void)?)
    func hideLoadingView()
    func configGraphView(_ viewModel: CardSubscriptionDetailGraphViewModel?, type: CardSubscriptionGraphType)
    func showGlobalEmptyView()
    func showOptionsToUpdateSubscription(title: LocalizedStylableText,
                                         body: LocalizedStylableText,
                                         action: LocalizedStylableText,
                                         onActionable: @escaping (Bool) -> Void)
}

public final class CardSubscriptionsDetailViewController: UIViewController {
    @IBOutlet private weak var topSeparator: UIView!
    @IBOutlet private weak var containerView: UIView!
    
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(with: containerView)
        view.setScrollInsets(UIEdgeInsets(top: 0.0, left: 0.0, bottom: 11.0, right: 0.0))
        view.setSpacing(0.0)
        return view
    }()
    
    private var lastTableStatusIsOpen: Bool = false

    private let dependenciesResolver: DependenciesResolver
    private let presenter: CardSubscriptionsDetailPresenterProtocol
    
    init(dependenciesResolver: DependenciesResolver, presenter: CardSubscriptionsDetailPresenterProtocol) {
        self.dependenciesResolver = dependenciesResolver
        self.presenter = presenter
        super.init(nibName: "CardSubscriptionsDetailViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
}

private extension CardSubscriptionsDetailViewController {
    func setupView() {
        view.backgroundColor = .clear
        topSeparator.backgroundColor = .lightSkyBlue
        containerView.backgroundColor = .white
    }
    
    // MARK: Navigation Bar
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(style: .white,
                                           title: .title(key: "genericToolbar_title_detail"))
        builder.setRightActions(.close(action: #selector(didTapInDismiss)))
        builder.build(on: self, with: nil)
    }
    
    @objc func didTapInDismiss() {
        presenter.dismiss()
    }
    
    // MARK: Custom stack views
    func addCardDetailView(_ viewModel: CardSubscriptionViewModel) {
        let view = CardSubscriptionDescriptionView()
        view.delegate = self
        view.configView(viewModel)
        scrollableStackView.addArrangedSubview(view)
    }
    
    func addGraphView(_ viewModel: CardSubscriptionDetailGraphViewModel?, type: CardSubscriptionGraphType) {
        let graphView = CardSubscriptionDetailGraphView()
        graphView.configView(viewModel, type: type)
        scrollableStackView.addArrangedSubview(graphView)
    }
    
    func addHistoricView(_ viewModels: [CardSubscriptionDetailHistoricViewModel], isOpen: Bool?) {
        if let isOpen = isOpen {
            lastTableStatusIsOpen = isOpen
        }
        updateHistoricViewIfNeeded()
        let view = CardSubscriptionDetailHistoricView()
        view.delegate = self
        view.configView(viewModels, isOpen: lastTableStatusIsOpen)
        scrollableStackView.addArrangedSubview(view)
    }
    
    func addGlobalEmptyView() {
        let view = CardSubscriptionDetailGlobalEmptyView()
        scrollableStackView.addArrangedSubview(view)
    }
    
    func addSeparatorView() {
        let separatorView = SeparatorView()
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        scrollableStackView.addArrangedSubview(separatorView)
    }
    
    // MARK: Update custom views in scrollableStack
    func updateHistoricViewIfNeeded() {
        scrollableStackView.getArrangedSubviews().forEach { (subView) in
            if let historicView  = subView as? CardSubscriptionDetailHistoricView {
                scrollableStackView.stackView.removeArrangedSubview(historicView)
                historicView.removeFromSuperview()
            }
        }
    }
}

extension CardSubscriptionsDetailViewController: CardSubscriptionsDetailViewProtocol {
    func configCardSubscriptionDetailView(_ viewModel: CardSubscriptionViewModel) {
        addCardDetailView(viewModel)
        addSeparatorView()
    }
    
    func updateCardSubscriptionDetailView(_ viewModel: CardSubscriptionViewModel) {
        scrollableStackView.getArrangedSubviews().forEach { (subView) in
            guard let cardDetailView = subView as? CardSubscriptionDescriptionView else {
                return
            }
            cardDetailView.configView(viewModel)
        }
    }
    
    func updateHistoricView(_ viewModels: [CardSubscriptionDetailHistoricViewModel], isOpen: Bool?) {
        addHistoricView(viewModels, isOpen: isOpen)
    }
    
    func configGraphView(_ viewModel: CardSubscriptionDetailGraphViewModel?, type: CardSubscriptionGraphType) {
        addGraphView(viewModel, type: type)
        addSeparatorView()
    }
    
    func showGlobalEmptyView() {
        addGlobalEmptyView()
        addSeparatorView()
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
                                              action: onAccept))),
            .margin(12.0)
        ]
        let builder = LisboaDialog(items: components, closeButtonAvailable: true)
        builder.showIn(self)
    }
}

extension CardSubscriptionsDetailViewController: DidTapInCardSubscriptionDescriptionDelegate {
    public func didTapInSubscriptionSwitch(_ isOn: Bool) {
        presenter.didTapInSubscriptionSwitch(isOn)
    }
}

extension CardSubscriptionsDetailViewController: LoadingViewPresentationCapable {
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

extension CardSubscriptionsDetailViewController: DidTapInHistoricSeeMorePaymentsDelegate {
    public func didTapInSeeMorePayments(_ isOpen: Bool) {
        presenter.didTapInSeeMorePayments(isOpen)
    }
    
    public func didSelectSeeFrationateOptions(_ viewModel: CardSubscriptionDetailHistoricViewModel) {
        presenter.didSelectSeeFrationateOptions(viewModel)
    }
}
