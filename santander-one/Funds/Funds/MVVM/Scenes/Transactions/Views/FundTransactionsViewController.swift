//
//  FundTransactionsViewController.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 28/3/22.
//

import UI
import UIKit
import Foundation
import OpenCombine
import CoreFoundationLib
import CoreDomain
import UIOneComponents

final class FundTransactionsViewController: UIViewController {

    @IBOutlet private weak var tableView: FundTransactionsTableView!
    @IBOutlet private weak var compressedHeaderView: CompressedFundTransactionsHeaderView!
    @IBOutlet private weak var compressedHeaderViewTopConstraint: NSLayoutConstraint!

    private let viewModel: FundTransactionsViewModel
    private let dependencies: FundTransactionsDependenciesResolver
    private var anySubscriptions: Set<AnyCancellable> = []
    private var fullScreenLoading: LoadingActionProtocol?
    let fundSubject = PassthroughSubject<FundRepresentable, Never>()
    let fundTransactionsSubject = PassthroughSubject<FundMovements, Never>()
    let movementDetailsSubject = PassthroughSubject<FundMovementDetails, Never>()
    let didSelectMovementDetailSubject = PassthroughSubject<(movement: FundMovementRepresentable, fund: FundRepresentable), Never>()
    var selectedFundMovementView: FundMovementView?
    var selectedCellModel: FundTransactionTableViewCellModel?

    private var isLoadingFullScreen: Bool {
        didSet {
            isLoadingFullScreen ?
            configureAndShowFullScreenLoading() :
            fullScreenLoading?.hideLoading(completion: nil)
        }
    }

    init(dependencies: FundTransactionsDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        self.isLoadingFullScreen = false
        super.init(nibName: "FundTransactionsViewController", bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollapsedHeader()
        bind()
        viewModel.viewDidLoad()
    }

    func tableViewUpdate() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            if #available(iOS 11.0, *) {
                self?.tableView.performBatchUpdates(nil, completion: nil)
            } else {
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
        }
    }
}

private extension FundTransactionsViewController {
    func setupNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "funds_title_ordersTransactions")
            .setLeftAction(.back, customAction: {
                self.didSelectGoBack()
            })
            .setRightAction(.menu) {
                self.didSelectOpenMenu()
            }
            .build(on: self)
    }

    @objc func didSelectGoBack() {
        viewModel.didSelectGoBack()
    }

    @objc func didSelectOpenMenu() {
        viewModel.didSelectOpenMenu()
    }

    func setupCollapsedHeader() {
        compressedHeaderView.didSelectFilterButton = { [weak self] in
            self?.viewModel.goToFilter()
        }
    }

    func hideCollapsedHeader() {
        guard self.compressedHeaderViewTopConstraint.constant == 0 else { return }
        self.compressedHeaderView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.compressedHeaderViewTopConstraint.constant = -(self?.compressedHeaderView.frame.height ?? 0)
            self?.view.layoutIfNeeded()
        }) { _ in
            self.compressedHeaderView.isHidden = true
        }
    }

    func showCollapsedHeader() {
        guard self.compressedHeaderViewTopConstraint.constant == -self.compressedHeaderView.frame.height else { return }
        self.compressedHeaderView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.compressedHeaderViewTopConstraint.constant = 0
            self?.view.layoutIfNeeded()
        })
    }

    func updateHeaderState(offset: CGPoint) {
        if offset.y < 160 {
            self.hideCollapsedHeader()
        } else {
            self.showCollapsedHeader()
        }
    }

    func configureAndShowFullScreenLoading() {
            let info = LoadingInfo(type: .onScreenCentered(controller: self.associatedLoadingView, completion: nil),
                                   loadingText: LoadingText(title: localized("")),
                                   loadingImageType: .jumps,
                                   loaderAccessibilityIdentifier: AccessibilityIdFundLoading.icnLoader.rawValue)
            fullScreenLoading = LoadingCreator.createAndShowLoading(info: info)
        }

    func bind() {
        bindTransactions()
        bindTransactionDetail()
        bindScrollManager()
    }

    func bindTransactions() {
        let fundMovementsPublisher = viewModel.state
            .case(FundTransactionsState.movementsLoaded)
            .map {
                FundMovements(fund: $0.fund, movements: $0.movementList, dependencies: self.dependencies)
            }.share()

        let fundMovementsErrorPublisher = viewModel.state
            .case(FundTransactionsState.movementsError)
            .map { [unowned self] _ in
                FundMovements(fund: viewModel.fund!, movements: [], dependencies: self.dependencies)
            }.subscribe(fundTransactionsSubject)
            .store(in: &anySubscriptions)

        fundMovementsPublisher
            .subscribe(fundTransactionsSubject)
            .store(in: &anySubscriptions)

        fundMovementsPublisher
            .subscribe(self.compressedHeaderView.selectFundSubject)
            .store(in: &self.anySubscriptions)

        viewModel.state
            .case(FundTransactionsState.isTransactionLoading)
            .sink {[unowned self] loading in
                if loading {
                    self.tableView.changeInfoState(infoState: .loading)
                    self.tableView.clean()
                } else {
                    self.tableView.changeInfoState(infoState: .none, reload: false)
                }
            }.store(in: &anySubscriptions)

        viewModel.state
            .case(FundTransactionsState.isPaginationLoading)
            .sink {[unowned self] loading in
                if loading {
                    self.tableView.changeInfoState(infoState: .loadingPage)
                } else {
                    self.tableView.changeInfoState(infoState: .none, reload: false)
                }
            }.store(in: &anySubscriptions)

        self.fundTransactionsSubject
            .map { $0  }
            .sink { [unowned self] fund in
                self.tableView.bind(headerItem: fund) { indexPath, cell, item in
                    cell?.configure(withViewModel: fund, andFilters: self.viewModel.filters)
                    cell?.didSelectFilterButton = { [weak self] in
                        self?.viewModel.goToFilter()
                    }
                    cell?.updatedFilters = { [weak self] filters in
                        if self?.viewModel.filters != nil, filters.isNil {
                            self?.viewModel.trackEvent(.clear)
                        }
                        self?.viewModel.updateFilters(with: filters)
                    }
                    cell?.clearFilters = { [weak self] in
                        self?.viewModel.trackEvent(.clearAll)
                        self?.viewModel.updateFilters(with: nil)
                    }
                }
                self.tableView.bind(movementItem: fund) { indexPath, cell, fundMovements, fundMovementRepresentable in
                    cell?.configure(withViewModel: fundMovements, cellModel: fundMovementRepresentable, viewController: self)
                }
                fund.movements.isEmpty ? self.tableView.changeInfoState(infoState: .empty, reload: false) : self.tableView.changeInfoState(infoState: .none, reload: false)
                self.tableView.reloadData()
            }.store(in: &self.anySubscriptions)

        self.tableView
            .didLoadMoreMovementsSubject
            .sink {
                self.viewModel.didLoadMoreMovements()
            }.store(in: &self.anySubscriptions)
    }

    func bindTransactionDetail() {
        let fundMovementDetailsPublisher = viewModel.state
            .case(FundTransactionsState.movementDetailLoaded)
            .map { [unowned self] in
                FundMovementDetails(fund: $0.fund, movement: $0.movement, movementDetails: $0.movementDetails, transactionsDependencies: self.dependencies)
            }.share()

        fundMovementDetailsPublisher
            .subscribe(movementDetailsSubject)
            .store(in: &anySubscriptions)

        self
            .didSelectMovementDetailSubject
            .sink { [unowned self] (movement: FundMovementRepresentable, fund: FundRepresentable) in
                self.viewModel.didSelectMovementDetail(for: movement, in: fund)
            }.store(in: &anySubscriptions)

        self.movementDetailsSubject
            .sink { [unowned self] fundMovementDetails in
                self.selectedFundMovementView?.setDetailView(fundMovementDetails)
                self.selectedCellModel?.isOpened = true
                self.selectedCellModel?.detail = fundMovementDetails
                self.tableViewUpdate()
            }.store(in: &self.anySubscriptions)

        viewModel.state
            .case(FundTransactionsState.isTransactionDetailLoading)
            .sink { [unowned self] isMovementDetailLoading in self.isLoadingFullScreen = isMovementDetailLoading }
            .store(in: &anySubscriptions)
    }

    func bindScrollManager() {
        self.tableView.bindableDatasource
            .scrollViewDidScroll
            .sink { [unowned self] point in
                self.updateHeaderState(offset: point)
            }.store(in: &self.anySubscriptions)

        self.tableView.bindableDatasource
            .scrollViewDidEndDecelerating
            .sink { [unowned self] point in
                self.updateHeaderState(offset: point)
            }.store(in: &self.anySubscriptions)
    }
}

extension FundTransactionsViewController: LoadingViewPresentationCapable {}

extension FundTransactionsViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}
