import UI
import UIKit
import Foundation
import OpenCombine
import CoreFoundationLib
import CoreDomain

final class CardDetailViewController: UIViewController {
    @IBOutlet private weak var cardDetailAnimationViewbottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cardDetailAnimationView: CardDetailAnimationView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var cardStackView: UIStackView!
    @IBOutlet private weak var cardContainerView: UIView!
    @IBOutlet private weak var cardDetailDataView: CardDetailDataView!
    @IBOutlet private weak var cardDetailSubdataView: CardDetailSubdataView!
    private let navigationBarItemBuilder: NavigationBarItemBuilder
    @IBOutlet weak var cardContainerViewTop: NSLayoutConstraint!
    private var dependenciesResolver: DependenciesResolver {
        dependencies.external.resolve()
    }
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setSpacing(0)
        view.setup(with: self.containerView)
        return view
    }()
    private let viewModel: CardDetailViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: CardDetailDependenciesResolver
    
    init(dependencies: CardDetailDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        self.navigationBarItemBuilder = dependencies.external.resolve()
        super.init(nibName: "CardDetail", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        loadData()
    }
    
}

private extension CardDetailViewController {
    func loadData() {
        setAppearance()
        bind()
        viewModel.viewDidLoad()
    }
    
    func setAppearance() {
        self.cardDetailDataView.isHidden = true
        self.containerView.isHidden = true
        self.separatorView.backgroundColor = .skyGray
        self.view.backgroundColor = .skyGray
        self.cardContainerView.backgroundColor = .skyGray
    }
    
    func bind() {
        bindCardDetail()
    }
    
    func bindCardDetail() {
        viewModel.state
            .case(CardDetailState.dataLoaded)
            .sink { [unowned self] card in
                setupHeader(card)
                setupViews(card: card)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(CardDetailState.detailError)
            .sink { [unowned self] _ in
                showError()
            }.store(in: &subscriptions)
        
        cardDetailDataView
            .onTouchButtonSubject
            .sink { [unowned self] _ in
                self.viewModel.didSelectActiveCard()
            }.store(in: &subscriptions)
    }
    
    func bindChangeAlias(editableView: CardProductDetailEditableView) {
        viewModel.state
            .case(CardDetailState.changeAlias)
            .sink { [unowned self] _ in
                self.dismissLoading {
                    self.showAliasChangedView(isError: false, subtitle: "cardDetail_label_aliasChanged")
                }
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(CardDetailState.changeAliasError)
            .sink { [unowned self] _ in
                self.dismissLoading {
                    self.showAliasDialog()
                }
            }.store(in: &subscriptions)
        
        editableView
            .onTouchAliasSubject
            .sink { [unowned self] alias in
                self.showLoading()
                self.viewModel.changeAlias(newAlias: alias)
            }.store(in: &subscriptions)
    }
    
    func bindActions(iconView: CardProductDetailIconView) {
        iconView
            .stateSubject
            .case(CardProductDetailIconState.didTapOnShowPAN)
            .sink { [unowned self] _ in
                self.viewModel.didTapOnShowPAN()
            }.store(in: &subscriptions)
        
        iconView
            .stateSubject
            .case(CardProductDetailIconState.didTapOnSharePAN)
            .sink { [unowned self] _ in
                self.viewModel.didTapOnSharePAN()
            }.store(in: &subscriptions)
        
        iconView
            .stateSubject
            .case(CardProductDetailIconState.didTapOnShareAccountNumber)
            .sink { [unowned self] _ in
                self.viewModel.didTapOnShareAccountNumber()
            }.store(in: &subscriptions)
    }
    
}

private extension CardDetailViewController {
    @objc func didSelectGoBack() {
        viewModel.didSelectGoBack()
    }
    
    @objc func didSelectOpenMenu() {
        viewModel.didSelectOpenMenu()
    }
    
    func setupViews(card: CardDetail) {
        self.cardDetailDataView.configure(card: card)
        self.cardDetailDataView.isHidden = false
        self.containerView.isHidden = false
        self.separatorView.isHidden = false
        self.addProductViews(card: card)
    }
    
    func setupNavigationBar() {
        navigationBarItemBuilder
            .addStyle(.sky)
            .addTitle(.title(key: "toolbar_title_cardDetail"))
            .addLeftAction(.back, selector: #selector(didSelectGoBack))
            .addRightAction(.menu, selector: #selector(didSelectOpenMenu))
            .build(on: self)
    }
    
    func setupHeader(_ cardDetail: CardDetail) {
        if cardDetail.card.isCreditCard {
            guard let headerElements = cardDetail.cardDetailConfiguration?.creditCardHeaderElements else { return }
            setupCreditCardHeaderElements(options: headerElements, card: cardDetail)
        } else if cardDetail.card.isDebitCard {
            guard let headerElements = cardDetail.cardDetailConfiguration?.debitCardHeaderElements else { return }
            setupDebitCardHeaderElements(options: headerElements, card: cardDetail)
        } else if cardDetail.card.isPrepaidCard {
            guard let headerElements = cardDetail.cardDetailConfiguration?.prepaidCardHeaderElements else { return }
            setupPrepaidCardHeaderElements(options: headerElements, card: cardDetail)
        }
    }
    
    func setupCreditCardHeaderElements(options: [CreditCardHeaderElements], card: CardDetail) {
        let items: [CardDetailTitle] = options.map { option in
            switch option {
            case .availableCredit:
                return CardDetailTitle(title: "cardDetail_label_available", value: card.availableBalance ?? "")
            case .limitCredit:
                return CardDetailTitle(title: "cardDetail_label_limit", value: card.creditLimit ?? "" )
            case .withdrawnCredit:
                return CardDetailTitle(title: "cardDetail_label_proposed", value: card.withdrawnCreditAmount ?? "")
            }
        }
        updateView(items: items)
    }
    
    func setupDebitCardHeaderElements(options: [DebitCardHeaderElements], card: CardDetail) {
        let items: [CardDetailTitle] = options.map { option in
            switch option {
            case .atmLimit:
                return CardDetailTitle(title: "cardDetail_label_atmLimit", value: card.atmLimit ?? "")
            case .spentThisMonth:
                return CardDetailTitle(title: "cardDetail_label_spentMonth", value: card.withdrawnCreditAmount ?? "" )
            case .tradeLimit:
                return CardDetailTitle(title: "cardDetail_label_limitsCommerces", value: card.tradeLimit ?? "")
            }
        }
        updateView(items: items)
    }
    
    func setupPrepaidCardHeaderElements(options: [PrepaidCardHeaderElements], card: CardDetail) {
        let items: [CardDetailTitle] = options.map { option in
            switch option {
            case .availableBalance:
                return CardDetailTitle(title: "cardDetail_label_balance", value: card.availableBalance ?? "")
            case .spentThisMonth:
                return CardDetailTitle(title: "card_label_spentMonth", value: card.monthBalanceFormat ?? "" )
            }
        }
        updateView(items: items)
    }
    
    func updateView(items: [CardDetailTitle]) {
        if items.isNotEmpty {
            self.cardDetailSubdataView.setup(with: items)
        }
    }
    
    func setCardDetailAnimationView(title: String?, subtitle: String?) {
        self.cardDetailAnimationView.isHidden = true
        if let subtitle = subtitle {
            self.cardDetailAnimationView.setSuccessAnimationView(subtitle: subtitle)
        } else {
            self.cardDetailAnimationView.setErrorAnimationView(title: title ?? "")
        }
    }
    
    func showAnimatedView(_ completion: (() -> Void)?) {
        self.cardDetailAnimationView.isHidden = false
        self.cardDetailAnimationViewbottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] completed in
            guard completed else { return }
            self?.cardDetailAnimationViewbottomConstraint?.constant = -72
            UIView.animate(withDuration: 0.2, delay: 2, animations: {
                self?.view.layoutIfNeeded()
            }, completion: { [weak self] completed in
                guard completed else { return }
                self?.cardDetailAnimationView.isHidden = true
                completion?()
            })
        })
    }
    
    func addProductViews(card: CardDetail) {
        clearProductView()
        for field in card.products {
            switch field.type {
            case .basic:
                let cardTitle = CardDetailTitle(title: field.title, value: field.value)
                let cardProductDetailBasicView = CardProductDetailBasicView(frame: .zero)
                cardProductDetailBasicView.setupViewModel(title: cardTitle, type: field.dataType)
                cardProductDetailBasicView.translatesAutoresizingMaskIntoConstraints = false
                self.scrollableStackView.addArrangedSubview(cardProductDetailBasicView)
            case .icon(let masked):
                let cardTitle = CardDetailTitle(title: field.title, value: field.value)
                let cardProductDetailIconView = CardProductDetailIconView(frame: .zero)
                cardProductDetailIconView.setupViewModel(title: cardTitle,
                                                         isMasked: masked,
                                                         type: field.dataType)
                cardProductDetailIconView.translatesAutoresizingMaskIntoConstraints = false
                self.scrollableStackView.addArrangedSubview(cardProductDetailIconView)
                bindActions(iconView: cardProductDetailIconView)
            case .editable:
                let cardProductDetailEditableView = CardProductDetailEditableView(frame: .zero)
                let cardTitle = CardDetailTitle(title: field.title, value: field.value)
                cardProductDetailEditableView.configure(card: card, title: cardTitle, type: field.dataType)
                cardProductDetailEditableView.translatesAutoresizingMaskIntoConstraints = false
                self.scrollableStackView.addArrangedSubview(cardProductDetailEditableView)
                bindChangeAlias(editableView: cardProductDetailEditableView)
            }
        }
    }
    
    func clearProductView() {
        self.scrollableStackView.getArrangedSubviews().forEach {
            scrollableStackView.stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    func showAliasChangedView(isError: Bool, subtitle: String?) {
        if isError {
            self.setCardDetailAnimationView(title: "cardDetail_label_errorChangeAlias", subtitle: nil)
        } else {
            self.setCardDetailAnimationView(title: nil, subtitle: subtitle)
        }
        self.showAnimatedView(nil)
    }
    
    func showAliasDialog() {
        let acceptAction = DialogButtonComponents(titled: localized("generic_button_accept"), does: { [weak self] in
            self?.showAliasChangedView(isError: true, subtitle: "cardDetail_label_errorChangeAlias")
        })
        self.showOldDialog(
            title: nil,
            description: localized("generic_error_connection"),
            acceptAction: acceptAction,
            cancelAction: nil,
            isCloseOptionAvailable: true
        )
    }

    func showError() {
        self.showGenericErrorDialog(withDependenciesResolver: dependenciesResolver)
    }
    
}

extension CardDetailViewController: NavigationBarWithSearch {}

extension CardDetailViewController: OldDialogViewPresentationCapable { }

extension CardDetailViewController: LoadingViewPresentationCapable { }
