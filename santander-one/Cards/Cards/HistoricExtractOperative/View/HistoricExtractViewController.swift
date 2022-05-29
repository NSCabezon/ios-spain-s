//
//  HistoricExtractViewController.swift
//  Cards
//
//  Created by Ignacio González Miró on 16/11/2020.
//

import UIKit
import Operative
import UI
import CoreFoundationLib

protocol HistoricExtractViewProtocol: OperativeView {
    func setHeaderViewModel(_ headerViewModel: NextSettlementViewModel)
    func setGroupedViewModels(_ groupedViewModels: [GroupedMovementsViewModel])
    func updateHeaderView(_ viewModel: NextSettlementViewModel)
}

final class HistoricExtractViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var selectorView: MonthSelectorView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var headerView: HistoricExtractHeaderView!
    @IBOutlet private weak var historicTableView: HistoricExtractTableView!
    @IBOutlet private weak var emptyView: SingleEmptyView!
    @IBOutlet private weak var separatorView: UIView!
    
    var presenter: HistoricExtractPresenterProtocol
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: HistoricExtractPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        self.setDelegates()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
}

private extension HistoricExtractViewController {
    // MARK: Main methods
    func commonInit() {
        self.view.backgroundColor = .skyGray
        self.headerView.backgroundColor = UIColor.skyGray
        self.separatorView.backgroundColor = .mediumSkyGray
    }
    
    func setDelegates() {
        self.scrollView.delegate = self
        self.selectorView.delegate = self
        self.headerView.delegate = self
        self.historicTableView.tableDelegate = self
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: localized("toolbar_title_statementHistory"), identifier: "historicExtractTitle")
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(didSelectClose))
        )
        builder.build(on: self, with: nil)
    }
    
    func updateScrolls(_ isEnabled: Bool) {
        self.scrollView.isScrollEnabled = !isEnabled
        self.historicTableView.isScrollEnabled = isEnabled
    }
    
    // MARK: Navigation Actions
    @objc func didSelectClose() {
        presenter.didTapInClose()
    }
}

extension HistoricExtractViewController: HistoricExtractViewProtocol {
    func setHeaderViewModel(_ headerViewModel: NextSettlementViewModel) {
        self.headerView.configure(headerViewModel, isMapEnabled: presenter.isShoppingMapEnabled, isExtractPdfEnabled: presenter.isExtractPdfEnabled)
    }
    
    func updateHeaderView(_ viewModel: NextSettlementViewModel) {
        self.headerView.updateHeaderView(viewModel)
    }
    
    func setGroupedViewModels(_ groupedViewModels: [GroupedMovementsViewModel]) {
        self.emptyView.isHidden = groupedViewModels.count > 0
        if !self.emptyView.isHidden {
            self.scrollView.isScrollEnabled = true
            self.emptyView.updateTitle(localized("generic_label_emptyNotAvailableMoves"))
            self.emptyView.titleFont(UIFont.santander(family: .text, type: .regular, size: 18), color: .lisboaGray)
        }
        self.historicTableView.setGroupedViewModels(groupedViewModels)
    }
    
    var operativePresenter: OperativeStepPresenterProtocol {
        return self.presenter
    }
}

extension HistoricExtractViewController: HistoricExtractHeaderDelegate {
    func didTapInShopMap() {
        presenter.didTapInShopMapPill()
    }
    
    func didTapInPdfExtract() {
        presenter.didTapInPdfExtractPill()
    }
}

extension HistoricExtractViewController: DidTapInMonthSelectorDelegate {
    func didSelectMonth(_ differenceBetweenMonths: Int, dateName: String) {
        presenter.didSelectMonth(differenceBetweenMonths, dateName: dateName)
    }
}

extension HistoricExtractViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let actionButtonsViewHeight: CGFloat = 103
        let topMargin: CGFloat = 10
        let maxY = self.headerView.frame.size.height - (actionButtonsViewHeight - topMargin)
        let isScrollEnabled = scrollView.contentOffset.y >= maxY
        if isScrollEnabled {
            if emptyView.isHidden {
                self.updateScrolls(isScrollEnabled)
            }
            let contentOffset = CGPoint(x: 0, y: maxY)
            scrollView.setContentOffset(contentOffset, animated: false)
            scrollView.showsVerticalScrollIndicator = false
        }
        // In case small list
        let totalHeight = (historicTableView.contentSize.height + actionButtonsViewHeight)
        if historicTableView.contentOffset.y >= (totalHeight - historicTableView.frame.size.height) {
            self.updateScrolls(false)
        }
    }
}

extension HistoricExtractViewController: HistoricExtractTableDelegate {
    func tableScrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            self.updateScrolls(false)
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            scrollView.showsVerticalScrollIndicator = false
            scrollView.isScrollEnabled = false
        }
        self.scrollView.isScrollEnabled = scrollView.contentOffset.y <= 0
    }
}
