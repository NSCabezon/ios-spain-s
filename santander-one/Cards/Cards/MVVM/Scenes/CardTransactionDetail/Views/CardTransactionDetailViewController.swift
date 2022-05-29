//
//  CardTransactionDetailViewController.swift
//  Cards
//
//  Created by Hernán Villamil on 30/3/22.
//

import UI
import UIKit
import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

final class CardTransactionDetailViewController: UIViewController {
    private let scrollableStackView = ScrollableStackView(frame: .zero)
    let actionButtons = CardTransactionDetailActions()
    let fractionatePaymentView = FractionatePaymentView()
    let transactionCollectionView = CardTransactionCollectoinView(frame: .zero,
                                                                     collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var noLocationMapView = CardTransactionDetailWithoutLocationView()
    private lazy var mapView: CardTransactionDetailLocationView = CardTransactionDetailLocationView()
    private let viewModel: CardTransactionDetailViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: CardTransactionDetailDependenciesResolver
    private let navigationBarItemBuilder: NavigationBarItemBuilder
    
    init(dependencies: CardTransactionDetailDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        self.navigationBarItemBuilder = dependencies.external.resolve()
        super.init(nibName: "CardTransactionDetailViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - Appearance
private extension CardTransactionDetailViewController {
    @objc func didSelectGoBack() {
        viewModel.didSelectGoBack()
    }
    
    @objc func didSelectOpenMenu() {
        viewModel.didSelectOpenMenu()
    }
    
    func setAppearance() {
        view.backgroundColor = UIColor.skyGray
        setupNavigationBar()
        setScrollableStack()
    }
    
    func setScrollableStack() {
        scrollableStackView.setup(with: self.view)
        addTransactionCollectionView()
    }
    
    func setupNavigationBar() {
        navigationBarItemBuilder
            .addStyle(.sky)
            .addTitle(.title(key: "toolbar_title_movesDetail"))
            .setLeftAction(.back, associatedAction: .closure(didSelectGoBack))
            .addRightAction(.menu, associatedAction: .closure(didSelectOpenMenu))
            .build(on: self)
    }
}

// MARK: - Carrousel
private extension CardTransactionDetailViewController {
    func addTransactionCollectionView() {
        scrollableStackView.addArrangedSubview(transactionCollectionView)
    }
    func setupCell(_ cell: UICollectionViewCell?, indexPath: IndexPath, item: CardTransactionViewItemRepresentable) {
        guard let transactionCell = cell as? CardTransactionCollectionViewCell else { return }
        transactionCell.didSelectOffer = { [unowned self] item in
            guard let unwrappedItem = item else { return }
            self.viewModel.didSelectOffer(item: unwrappedItem)
        }
        transactionCell.didSelectFractionate = { [unowned self] in
            self.viewModel.didSelectFractionate()
        }
        transactionCell.stateSubject.send(.timeManager(dependencies.external.resolve()))
        transactionCell.stateSubject.send(.item(item))
    }
}

// MARK: - Map
private extension CardTransactionDetailViewController {
    func removeMapViews() {
        mapView.removeFromSuperview()
        noLocationMapView.removeFromSuperview()
    }
    
    func addNoLocationMapView() {
        removeMapViews()
        scrollableStackView.insetArrangedSubview(noLocationMapView, at: 1)
    }
    
    func addLocationMapView() {
        removeMapViews()
        scrollableStackView.insetArrangedSubview(mapView, at: 1)
    }
}

// MARK: - Actions
private extension CardTransactionDetailViewController {
    func addActionsButtons() {
        actionButtons.removeSubviews()
        scrollableStackView.addArrangedSubview(actionButtons)
    }
}

// MARK: - Fractionable
private extension CardTransactionDetailViewController {
    func addFractionableView() {
        scrollableStackView.addArrangedSubview(fractionatePaymentView)
    }
    
    func removeFractionableView() {
        fractionatePaymentView.removeFromSuperview()
    }
}

// MARK: - Bind
private extension CardTransactionDetailViewController {
    func bind() {
        bindTransactions()
        bindeDefaultSelectedTransaction()
        bindNotLocalizableTransaction()
        bindTemporallyNotLocalizabletransaction()
        bindLocalizableTransaction()
        bindFractionableView()
        bindSelectedTransaction()
        bindDetailDidLoad()
        bindUpdateItemInColelctionView()
        bindAddActions()
        bindMapSelected()
        bindMonthlyFeeSelected()
        bindNotAvailable()
    }
    
    func bindTransactions() {
        viewModel.state
            .case(CardTransactionDetailState.didLoadTransactions)
            .sink { [unowned self] items in
                transactionCollectionView.bind(items: items) { (indexPath, cell, item) in
                    self.setupCell(cell, indexPath: indexPath, item: item)
                }
            }.store(in: &subscriptions)
    }
    
    func bindNotLocalizableTransaction() {
        viewModel.state
            .case(CardTransactionDetailState.didLoadTransactionNoLocalizable)
            .sink {  [unowned self] _ in
                self.addNoLocationMapView()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(CardTransactionDetailState.didLoadTransactionNoLocalizable)
            .compactMap { localized("transaction_text_geolocationNotAllowed") }
            .assign(to: \.title, on: noLocationMapView)
            .store(in: &subscriptions)
    }
    
    func bindTemporallyNotLocalizabletransaction() {
        viewModel.state
            .case(CardTransactionDetailState.didLoadTransactionTemporallyNotLocalizable)
            .sink { [unowned self] _ in
                self.addNoLocationMapView()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(CardTransactionDetailState.didLoadTransactionTemporallyNotLocalizable)
            .compactMap { localized("transaction_text_geolocationPending") }
            .assign(to: \.title, on: noLocationMapView)
            .store(in: &subscriptions)
    }
    
    func bindLocalizableTransaction() {
        viewModel.state
            .case(CardTransactionDetailState.didLoadTransactionLocation)
            .sink { [unowned self] _ in
                self.addLocationMapView()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(CardTransactionDetailState.didLoadTransactionLocation)
            .compactMap { $0 }
            .assign(to: \.item, on: mapView)
            .store(in: &subscriptions)
        
    }
    
    func bindFractionableView() {
        viewModel.state
            .case(CardTransactionDetailState.removeFractionatedPayment)
            .sink {  [unowned self] _ in
                self.removeFractionableView()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(CardTransactionDetailState.didLoadFractionatedPayment)
            .sink {  [unowned self] _ in
                self.addFractionableView()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(CardTransactionDetailState.didLoadFractionatedPayment)
            .compactMap { $0 }
            .assign(to: \.item, on: fractionatePaymentView)
            .store(in: &subscriptions)
        
    }
    
    func bindSelectedTransaction() {
        transactionCollectionView.didSelectTransactionSubject
            .sink { [unowned self] item in
                self.viewModel.didSelectTransaction(item.transaction)
            }.store(in: &subscriptions)
    }
    
    func bindeDefaultSelectedTransaction() {
        viewModel.state
            .case(CardTransactionDetailState.didSelectTransaction)
            .sink { [unowned self] item in
                self.transactionCollectionView.scrollTo(item)
            }.store(in: &subscriptions)
        
    }
    
    func bindDetailDidLoad() {
        let detailPublisher = viewModel.state
            .case(CardTransactionDetailState.didLoadDetail)
            .share()
        detailPublisher
            .subscribe(transactionCollectionView.didLoadTransactionSubject)
            .store(in: &subscriptions)
    }
    
    func bindUpdateItemInColelctionView() {
        viewModel.state
            .case(CardTransactionDetailState.updateItem)
            .sink { [unowned self] item in
                    self.transactionCollectionView.updateItem(item)
            }.store(in: &subscriptions)
    }
    
    func bindAddActions() {
        viewModel.state
            .case(CardTransactionDetailState.didLoadActions)
            .filter { $0.count > 1 }
            .sink { [unowned self] actions in
                self.addActionsButtons()
                self.actionButtons.stateSubject.send(.items(actions))
            }.store(in: &subscriptions)
    }
    
    func bindNotAvailable() {
        viewModel.state
            .case(CardTransactionDetailState.notAvailable)
            .sink { _ in
                Toast.show(localized("generic_alert_notAvailableOperation"))
            }.store(in: &subscriptions)
    }
    
    func bindMapSelected() {
        mapView.didSelectMapSubject
            .sink { [unowned self] _ in
                self.viewModel.didSelectMap()
            }.store(in: &subscriptions)
    }
    
    func bindMonthlyFeeSelected() {
        fractionatePaymentView.didSelectMonthlyFee
            .sink { [unowned self] fee in
                self.viewModel.didSelectMonthlyFee(fee)
            }.store(in: &subscriptions)
    }
}
