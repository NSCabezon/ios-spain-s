//
//  NextSettlementViewController.swift
//  Cards
//
//  Created by Laura González on 05/10/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol NextSettlementViewProtocol: AnyObject {
    func setTicketViewModel(_ configuration: NextSettlementViewModel)
    func reloadTicketViewModel(_ configuration: NextSettlementViewModel)
    func setActions(_ viewModels: [NextSettlementActionViewModel])
    func setLoadingView()
    func hideLoadingView(completion: (() -> Void)?)
    func showCreditCardFAQs(_ creditCardFAQs: [FaqsEntity]?, baseUrl: String)
}

final class NextSettlementViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var ticketView: NextSettlementTicketView!
    @IBOutlet private weak var actionButtonView: NextSettlementActionView!
    @IBOutlet private weak var faqsView: NextSettlementFaqsView!
    
    private let presenter: NextSettlementPresenterProtocol
    private var viewModel: NextSettlementViewModel?
    private var cardPickerTableView: CardSelectorTableView = {
        let tableView = CardSelectorTableView()
        return tableView
    }()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: NextSettlementPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .skyGray
        presenter.viewDidLoad()
        setAccessibilityIdentifiers()
        self.setCardSelectorTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNavigationBar()
    }
}

extension NextSettlementViewController: NextSettlementFaqsViewDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

private extension NextSettlementViewController {
    func setUpNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .custom(background: .color(.skyGray), tintColor: .santanderRed),
            title: .title(key: "toolbar_title_nextSettlement")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.close(action: #selector(dismissViewController)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    func setAccessibilityIdentifiers() {
        ticketView.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.ticketView.rawValue
    }
    
    // MARK: CardPicker Selector - Collapsed tableView
    func setCardSelectorTableView() {
        self.cardPickerTableView.register(CardSelectorCell.self, bundle: CardSelectorCell.bundle)
        self.cardPickerTableView.cardDelegate = self
        self.scrollView.addSubview(cardPickerTableView)
    }
    
    func updateScrollViewHeight(_ cardSelectorTableHeight: CGFloat) {
        let updatedScrollHeight = self.scrollView.frame.size.height + cardSelectorTableHeight
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: updatedScrollHeight)
        self.scrollView.setNeedsDisplay()
    }
    
    func displayAnimation(_ isCollapsed: Bool, ownerCards: [OwnerCards]) {
        self.cardPickerTableView.isHidden = isCollapsed
        self.cardPickerTableView.frame = CGRect(x: self.ticketView.ticketContainerView.frame.origin.x, y: (self.ticketView.cardSelector?.frame.maxY ?? 0), width: self.ticketView.ticketContainerView.frame.size.width, height: 0)
        let tableHeight: CGFloat = 60.0 * CGFloat(ownerCards.count)
        self.cardPickerTableView.setupData(ownerCards)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: .curveLinear, animations: {
            self.cardPickerTableView.frame.size.height = !isCollapsed ? tableHeight : CGFloat.zero
            self.cardPickerTableView.setNeedsDisplay()
        }, completion: { _ in
            self.cardPickerTableView.flashScrollIndicators()
            self.updateScrollViewHeight(tableHeight)
        })
    }
}

extension NextSettlementViewController: NextSettlementViewProtocol {
    func setActions(_ viewModels: [NextSettlementActionViewModel]) {
        actionButtonView.setActions(viewModels)
    }
    
    func setTicketViewModel(_ configuration: NextSettlementViewModel) {
        self.viewModel = configuration
        self.ticketView.setViewModel(configuration, lastMovementsViewDelegate: self)
    }
    
    func reloadTicketViewModel(_ configuration: NextSettlementViewModel) {
        self.ticketView.reloadViewModel(configuration)
    }
    
    func showCreditCardFAQs(_ creditCardFAQs: [FaqsEntity]?, baseUrl: String) {
        guard let creditCardFAQs = creditCardFAQs, !creditCardFAQs.isEmpty else { return faqsView.isHidden = true }
        let creditFAQS = creditCardFAQs.map { TripFaqViewModel(iconName: ($0.icon ?? ""),
                                                               titleKey: $0.question,
                                                               descriptionKey: $0.answer,
                                                               baseURL: baseUrl)
        }
        faqsView.addFaqs(creditFAQS)
        faqsView.delegate = self
        faqsView.isHidden = false
    }
}

extension NextSettlementViewController: LoadingViewPresentationCapable {
    var associatedLoadingView: UIViewController {
        return self
    }
    
    func setLoadingView() {
        self.showLoading()
    }
    
    func hideLoadingView(completion: (() -> Void)?) {
        self.dismissLoading(completion: completion)
    }
}

extension NextSettlementViewController: LastMovementsViewDelegate {
    func didMoreMovementsSelected() {
        self.presenter.didMoreMovementsSelected()
    }
}

extension NextSettlementViewController: DidTapInCardsSegmentedDelegate {
    func didTapInCardSegmented(_ index: Int) {
        self.presenter.didTapInOtherCard(index)
    }
}

extension NextSettlementViewController: DidTapInCardPickerSelectorDelegate {
    func didTapInSelector(_ isCollapsed: Bool) {
        guard let viewModel = self.viewModel, let ownerCards = viewModel.ownerCards, !ownerCards.isEmpty else {
            self.cardPickerTableView.frame = CGRect.zero
            return
        }
        self.ticketView.cardSelector?.updateSeparatorColor()
        self.displayAnimation(isCollapsed, ownerCards: ownerCards)
    }
}

extension NextSettlementViewController: DidTapInCardPickerTableDelegate {
    func didTapInCardPickerTable(_ index: Int) {
        guard let ownerCards = viewModel?.ownerCards else { return }
        self.ticketView.cardSelector?.configCardSelector(ownerCards[index], numberOfCards: String(ownerCards.count), isCollapsed: true)
        self.cardPickerTableView.isHidden = true
        self.cardPickerTableView.setNeedsDisplay()
        self.presenter.didTapPickerCard(index)
    }
}
