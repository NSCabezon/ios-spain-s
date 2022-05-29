//
//  LoanHeaderView.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/10/19.
//

import UI
import UIKit
import CoreFoundationLib
import CoreDomain
import OpenCombine

private extension LoansHeaderView {
    struct Appearance {
        let leadingAnchorSV: CGFloat = 16
        let trailingAnchorSV: CGFloat = -16
    }
}

enum LoansFilterState: State {
    case idle
    case loaded(TransactionFiltersRepresentable?)
    case remove(ActiveFilters?)
    case removeAll(Bool)
}

final class LoansHeaderView: XibView {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak private var actionButtonsStackView: UIStackView!
    @IBOutlet weak private var pageControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: LoansCollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var actionsHeaderView: MovementsHeaderView?
    private var stackViewBorderConstraints = [NSLayoutConstraint]()
    private var stackViewWidthConstraint: NSLayoutConstraint?
    private var anySubscriptions = Set<AnyCancellable>()
    private let appearance = Appearance()
    let optionsSubject = CurrentValueSubject<[LoanHomeOption], Never>([])
    let didSelectOptionSubject = PassthroughSubject<(option: LoanHomeOption, loan: Loan), Never>()
    let filterStateSubject = PassthroughSubject<LoansFilterState, Never>()
    var tagsContainerView: TagsContainerView? = TagsContainerView()
    private var filters: TransactionFilterViewModel?
    var loan: Loan?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bind()
    }

    @objc private func didTapOption(_ gesture: UIGestureRecognizer) {
        guard let actionButton = gesture.view as? ActionButton else { return }
        guard let optionViewModel = actionButton.getViewModel() as? LoanHomeOption else { return }
        guard let loan = self.loan else { return }
        didSelectOptionSubject.send((optionViewModel, loan))
    }
}

extension LoansHeaderView: ProductHomeHeaderViewProtocol {
    
    func updateHeaderAlpha(_ alpha: CGFloat) {
        self.collectionView.alpha = alpha
        self.pageControl.alpha = alpha
        self.actionButtonsStackView.arrangedSubviews.forEach { button in
            button.alpha = alpha
        }
    }
}

private extension LoansHeaderView {
    func bind() {
        optionsSubject
            .sink { [unowned self] options in
                self.actionButtonsStackView.distribution = options.count > 1 ? .fillEqually : .fill
                self.setupStackView(totalOptions: options.count)
                self.addActionButtons(with: options)
            }.store(in: &anySubscriptions)
        
        filterStateSubject
            .case { LoansFilterState.loaded }
            .filter { $0 == nil }
            .sink { [unowned self] _ in
                self.removeAllFilters()
            }.store(in: &anySubscriptions)
        
        filterStateSubject
            .case { LoansFilterState.loaded }
            .compactMap({ $0 })
            .map(TransactionFilterViewModel.init)
            .sink { [unowned self] filters in
                self.filters = filters
                self.tagsContainerView?.removeFromSuperview()
                guard let tagsMetadata = filters?.buildTags() else { return }
                self.addTagContainer(withTags: tagsMetadata)
            }.store(in: &anySubscriptions)
        
        tagsContainerView?
            .deleteTagsPublisher
            .sink { [unowned self] tags in
                guard tags.count > 0 else {
                    self.removeAllFilters()
                    self.filterStateSubject.send(.removeAll(true))
                    return
                }
                let filter = self.filters?.activeFilter(remainings: tags)
                filterStateSubject.send(.remove(filter))
            }.store(in: &anySubscriptions)
    }
    
    func removeAllFilters() {
        self.filters = nil
        self.tagsContainerView?.removeFromSuperview()
    }
    
    func setupView() {
        self.setupPageControl()
        self.backgroundColor = .skyGray
        self.actionsHeaderView?.clipsToBounds = true
        self.stackViewBorderConstraints.append(self.actionButtonsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: appearance.leadingAnchorSV))
        self.stackViewBorderConstraints.append(self.actionButtonsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: appearance.trailingAnchorSV))
        self.stackViewWidthConstraint = self.actionButtonsStackView.widthAnchor.constraint(equalToConstant: 168)
    }
    
    func setupPageControl() {
        let pages = collectionView.numberOfItems(inSection: 0)
        self.pageControl.accessibilityIdentifier = AccessibilityIDLoansHome.pageControl.rawValue
        self.pageControl.numberOfPages = pages
        self.pageControl.hidesForSinglePage = true
        self.pageControl.isHidden = pages <= 1
        self.pageControl.pageIndicatorTintColor = .silverDark
        self.pageControl.currentPageIndicatorTintColor = .botonRedLight
        if #available(iOS 14.0, *) {
            self.pageControlHeightConstraint.isActive = false
            self.pageControl.backgroundStyle = .minimal
        }
        self.pageControl.addTarget(self, action: #selector(pageControlSelectionAction(_:)), for: .valueChanged)
    }
    
    func addTagContainer(withTags tags: [TagMetaData]) {
        guard let tagsContainerView = self.tagsContainerView else { return }
        tagsContainerView.addTags(from: tags)
        tagsContainerView.backgroundColor = .white
        self.stackView.addArrangedSubview(tagsContainerView)
        tagsContainerView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
    }

    @objc func pageControlSelectionAction(_ pageControl: UIPageControl) {
        let index = IndexPath(item: pageControl.currentPage, section: 0)
        self.collectionView.scrollTo(index)
    }
}

extension LoansHeaderView: ProductHomeHeaderWithTagsViewProtocol {}

private extension LoansHeaderView {

    func setupActionButtons(enabled: Bool) {
        self.actionButtonsStackView.isUserInteractionEnabled = enabled
        self.actionsHeaderView?.isUserInteractionEnabled = enabled
    }

    func addActionButtons(with values: [LoanHomeOption]) {
        self.actionButtonsStackView.removeAllArrangedSubviews()
        values.forEach { viewModel in
            let actionButton = self.createActionButton()
            actionButton.addSelectorAction(target: self, #selector(self.didTapOption))
            actionButton.accessibilityIdentifier = viewModel.accessibilityIdentifier
            actionButton.setViewModel(viewModel)
            self.actionButtonsStackView.addArrangedSubview(actionButton)
        }
    }
    
    func createActionButton() -> ActionButton {
        let actionButton = ActionButton()
        actionButton.setExtraLabelContent(nil)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = NSLayoutConstraint(item: actionButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: .zero)
        widthConstraint.priority = .defaultLow
        widthConstraint.isActive = true
        return actionButton
    }
    
    func setupStackView(totalOptions: Int) {
        self.actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        if totalOptions > 1 {
            self.stackViewWidthConstraint?.isActive = false
            self.stackViewBorderConstraints.forEach({ $0.isActive = true })
        } else {
            self.stackViewBorderConstraints.forEach({ $0.isActive = false })
            self.stackViewWidthConstraint?.isActive = true
        }
    }
}
