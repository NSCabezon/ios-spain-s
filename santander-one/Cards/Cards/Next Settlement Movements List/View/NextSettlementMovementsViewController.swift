//
//  NextSettlementMovementsViewController.swift
//  Cards
//
//  Created by David Gálvez Alonso on 14/10/2020.
//

import UI
import CoreFoundationLib

protocol NextSettlementMovementsViewProtocol: AnyObject {
    func setActions(_ viewModels: [NextSettlementActionViewModel])
    func setHeaderViewModel(_ configuration: NextSettlementViewModel)
    func setGroupedViewModels(_ groupedViewModels: [GroupedMovementsViewModel])
    func setCardSegmentedView(_ viewModel: NextSettlementViewModel)
    func setCardSelector(_ viewModel: NextSettlementViewModel)
    func setTotalAmount(_ viewModels: [NextSettlementMovementViewModel])
    func scrollTableViewToTop()
}

final class NextSettlementMovementsViewController: UIViewController {

    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerView: SettlementMovementsHeaderView!
    @IBOutlet private weak var movementsTableView: UITableView!
    @IBOutlet private weak var segmentedView: LisboaSegmentedWithImageAndTitle!
    @IBOutlet private weak var totalExpensesView: SettlementMovementTotalCell!
    @IBOutlet private weak var cardSelector: CardSelectorWithImageAndTitle!
    @IBOutlet private weak var contentSegmentedView: UIStackView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var contentSeparatorView: UIView!
    @IBOutlet private weak var emptyView: SingleEmptyView!
    @IBOutlet private weak var segmentedTopConstraint: NSLayoutConstraint!
    
    private let presenter: NextSettlementMovementsPresenterProtocol
    private var groupedViewModels: [GroupedMovementsViewModel]?
    private var viewModel: NextSettlementViewModel?
    
    private var cardPickerTableView: CardSelectorTableView = {
        let tableView = CardSelectorTableView()
        return tableView
    }()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: NextSettlementMovementsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureTableView()
        presenter.viewDidLoad()
        setCardSelectorTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNavigationBar()
    }
}

private extension NextSettlementMovementsViewController {
    
    func setUpNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .custom(background: .color(.skyGray), tintColor: .santanderRed),
            title: .title(key: "toolbar_title_nextSettlement")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.close(action: #selector(dismissViewController)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    func configureView() {
        self.view.backgroundColor = .skyGray
        self.view.addGestureRecognizer(movementsTableView.panGestureRecognizer)
        movementsTableView.delegate = self
        movementsTableView.accessibilityIdentifier = AccessibilityCardsNextSettlementMovements.nextSettlementListTransaction.rawValue
        emptyView.updateTitle(localized("generic_label_emptyNotAvailableMoves"))
    }
    
    func configureTableView() {
        let cell = UINib(nibName: SettlementMovementGroupedTableViewCell.identifier, bundle: .module)
        self.movementsTableView.register(cell, forCellReuseIdentifier: SettlementMovementGroupedTableViewCell.identifier)
        let headerNib = UINib(nibName: SettlementMovementHeaderFooterView.identifier, bundle: Bundle.module)
        self.movementsTableView.register(headerNib, forHeaderFooterViewReuseIdentifier: SettlementMovementHeaderFooterView.identifier)
        self.movementsTableView.separatorStyle = .none
        self.movementsTableView.backgroundColor = .white
        self.movementsTableView.dataSource = self
        self.movementsTableView.delegate = self
        self.movementsTableView.contentInset.bottom = 6
    }
    
    // MARK: CardPicker Selector - Collapsed tableView
    func setCardSelectorTableView() {
        self.cardSelector.delegate = self
        self.cardPickerTableView.register(CardSelectorCell.self, bundle: CardSelectorCell.bundle)
        self.cardPickerTableView.cardDelegate = self
        self.view.addSubview(cardPickerTableView)
    }
    
    func displayAnimation(_ isCollapsed: Bool, ownerCards: [OwnerCards]) {
        self.cardPickerTableView.isHidden = isCollapsed
        let cardPickerBottomMargin: CGFloat = self.cardSelector.getBottomHeight()
        let cardPickerTableY = cardSelector.convert(cardSelector.bounds, to: self.view).maxY - cardPickerBottomMargin
        self.cardPickerTableView.frame = CGRect(x: self.contentSegmentedView.frame.origin.x,
                                                y: cardPickerTableY,
                                                width: self.cardSelector.frame.size.width, height: 0)
        let tableHeight: CGFloat = 60.0 * CGFloat(ownerCards.count)
        self.cardPickerTableView.setupData(ownerCards)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: .curveLinear, animations: {
            self.cardPickerTableView.frame.size.height = !isCollapsed ? tableHeight : CGFloat.zero
            self.cardPickerTableView.setNeedsDisplay()
        }, completion: { _ in
            self.cardPickerTableView.flashScrollIndicators()
        })
    }
    
    func changeConstraintsWhileScrolling(_ scrollView: UIScrollView) {
        if topConstraint.constant == headerView.getMaxScroll() && segmentedTopConstraint.constant <= contentSegmentedView.frame.height {
            segmentedTopConstraint.constant += scrollView.contentOffset.y
        }
        if segmentedTopConstraint.constant <= 0 {
            topConstraint.constant += scrollView.contentOffset.y
        }
    }
    
    func checkToStopTableScroll(_ scrollView: UIScrollView) {
        let maxScroll = headerView.getMaxScroll()
        let scrollValue = maxScroll - scrollView.contentOffset.y
        guard scrollValue >= 0 && scrollValue <= maxScroll && segmentedTopConstraint.constant <= contentSegmentedView.frame.height else {
            return
        }
        scrollView.contentOffset.y -= scrollView.contentOffset.y
    }
    
    func checkMaxMinContrains() {
        if topConstraint.constant > headerView.getMaxScroll() {
            topConstraint.constant = headerView.getMaxScroll()
        } else if topConstraint.constant < 0 {
            topConstraint.constant = 0
        }
        if segmentedTopConstraint.constant > contentSegmentedView.frame.height {
            segmentedTopConstraint.constant = contentSegmentedView.frame.height
        } else if segmentedTopConstraint.constant < 0 {
            segmentedTopConstraint.constant = 0
        }
    }
    
    func checkBounce() {
        guard movementsTableView.contentSize.height > movementsTableView.frame.height else {
            return
        }
        self.movementsTableView.alwaysBounceVertical = true
    }
}

extension NextSettlementMovementsViewController: NextSettlementMovementsViewProtocol {
    func setGroupedViewModels(_ groupedViewModels: [GroupedMovementsViewModel]) {
        self.groupedViewModels = groupedViewModels
        self.movementsTableView.reloadData()
        self.emptyView.isHidden = groupedViewModels.count > 0
        self.movementsTableView.alwaysBounceVertical = false
    }
    
    func setActions(_ viewModels: [NextSettlementActionViewModel]) {
        headerView.setActions(viewModels)
    }
    
    func setHeaderViewModel(_ configuration: NextSettlementViewModel) {
        self.headerView.addCardViewStyle(configuration)
    }
    
    func setCardSegmentedView(_ viewModel: NextSettlementViewModel) {        
        let orderButtons = viewModel.getOrderButtons()
        let primaryButton = viewModel.getCurrentCardSelected(orderButtons.principal)
        let secondaryButton = viewModel.getCurrentCardSelected(orderButtons.secondary)
        segmentedView.setInfo(primaryButton?.text ?? "", rightCardName: secondaryButton?.text ?? "", ownerCardUrl: primaryButton?.urlString ?? "", associatedCardUrl: secondaryButton?.urlString ?? "")
        if viewModel.getCurrentPanSelected == secondaryButton?.pan {
            segmentedView.setSecondarySegmentedSelected()
        }
        segmentedView.delegate = self
        segmentedView.isHidden = false
    }
    
    func scrollTableViewToTop() {
        self.topConstraint.constant = 0
        self.segmentedTopConstraint.constant = 0
        self.headerView.layer.shadowOpacity = 0
    }
    
    func setTotalAmount(_ viewModels: [NextSettlementMovementViewModel]) {
        guard viewModels.count > 0 else {
            totalExpensesView.isHidden = true
            return
        }
        let totalAmount = viewModels.lazy.compactMap { $0.amount }.reduce(0, +)
        let totalAmountString = Decimal(abs(totalAmount)).toStringWithCurrency()
        totalExpensesView.configureCell(totalAmountString)
        totalExpensesView.isHidden = false
        separatorView.isHidden = false
        separatorView.backgroundColor = .mediumSkyGray
        contentSeparatorView.isHidden = false
    }
    
    func setCardSelector(_ viewModel: NextSettlementViewModel) {
        self.viewModel = viewModel
        guard let card = viewModel.getCurrentCardSelected(viewModel.getCurrentPanSelected) else { return }
        cardSelector.configCardSelector(card, numberOfCards: String(viewModel.ownerCards?.count ?? 0), isCollapsed: true)
        cardSelector.isHidden = false
    }
}

extension NextSettlementMovementsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedViewModels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedViewModels?[section].movements.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettlementMovementGroupedTableViewCell.identifier, for: indexPath) as? SettlementMovementGroupedTableViewCell,
            let viewModel = groupedViewModels?[indexPath.section].movements[indexPath.row] else {
                return UITableViewCell()
        }
        cell.configureCell(viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettlementMovementHeaderFooterView.identifier)
            as? SettlementMovementHeaderFooterView else { return nil }
        headerView.configureWithDate(groupedViewModels?[section].formatedDate ?? "")
        tableView.removeUnnecessaryHeaderTopPadding()
        return headerView
    }
    
}

extension NextSettlementMovementsViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating else {
            return
        }
        headerView.layer.shadowOpacity = topConstraint.constant > 0.0 ? 0.4 : 0.0
        changeConstraintsWhileScrolling(scrollView)
        checkToStopTableScroll(scrollView)
        checkMaxMinContrains()
        checkBounce()
    }
}

extension NextSettlementMovementsViewController: DidTapInCardsSegmentedDelegate {
    func didTapInCardSegmented(_ index: Int) {
        presenter.didTapInCardSegmented(index)
    }
}

extension NextSettlementMovementsViewController: DidTapInCardPickerSelectorDelegate {
    func didTapInSelector(_ isCollapsed: Bool) {
        guard let viewModel = self.viewModel, let ownerCards = viewModel.ownerCards, !ownerCards.isEmpty else {
            self.cardPickerTableView.frame = CGRect.zero
            return
        }
        self.cardSelector.updateSeparatorColor()
        self.displayAnimation(isCollapsed, ownerCards: ownerCards)
    }
}

extension NextSettlementMovementsViewController: DidTapInCardPickerTableDelegate {
    func didTapInCardPickerTable(_ index: Int) {
        guard let ownerCard = self.viewModel?.ownerCards?[index], let numberOfCards = viewModel?.ownerCards?.count.description else {
            return
        }
        self.cardSelector.configCardSelector(ownerCard, numberOfCards: numberOfCards, isCollapsed: true)
        self.cardPickerTableView.isHidden = true
        self.cardPickerTableView.setNeedsDisplay()
        self.presenter.didTapPickerCard(index)
    }
}
