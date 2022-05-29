//
//  ExpensesIncomeCategoriesCharts.swift
//  Menu
//
//  Created by Mario Rosales Maillo on 9/6/21.
//

import CoreFoundationLib
import UI
import UIKit

protocol ExpensesIncomeCategoriesChartsProtocol {
    func didUpdateData(_ viewModel: ExpensesIncomeCategoriesViewModel)
}

protocol ExpensesIncomeCategoriesChartsDelegate: AnyObject {
    func didSelectCategory()
    func didShowChart(with type: ExpensesIncomeCategoriesView.AnalysisCategoryType, and viewModel: ExpensesIncomeCategoriesViewModel?, chartType: ExpensesIncomeCategoriesChartType)
    func categoryChartsDidSwipeWith(chartType: ExpensesIncomeCategoriesChartType)
}

final class ExpensesIncomeCategoriesCharts: XibView {
    
    private enum Config {
        static let pageHeight = CGFloat(28)
        static let tooltipCollectionHeight = CGFloat(400)
        static let collectionHeight = tooltipCollectionHeight - CategoriesChartCell.Config.disclaimerHeight
    }
    
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var chartsCollectionView: UICollectionView!
    @IBOutlet private weak var pageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var chartsCollectionConstraint: NSLayoutConstraint!

    public weak var delegate: ExpensesIncomeCategoriesChartsDelegate?
    private var chartsTypes: [ExpensesIncomeCategoriesChartType] = [.expenses, .payments]
    private var viewModel: ExpensesIncomeCategoriesViewModel? {
        didSet {
            self.reloadDataForCategoryType()
        }
    }
    
    private var categoryType: ExpensesIncomeCategoriesView.AnalysisCategoryType = .expenses {
        didSet {
            switch categoryType {
            case .expenses:
                self.chartsTypes = [.expenses, .payments]
            case .income:
                self.chartsTypes = [.incomes]
            }
            self.reloadDataForCategoryType()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
        
    public func didSelectAnalysisCategoryType(_ category: ExpensesIncomeCategoriesView.AnalysisCategoryType) {
        self.categoryType = category
    }
}

private extension ExpensesIncomeCategoriesCharts {
    
    func setupUI() {
        self.registerCell()
        self.chartsCollectionView.dataSource = self
        self.chartsCollectionView.delegate = self
        self.pageControl.addTarget(self, action: #selector(pageControlSelectionAction(_:)), for: .valueChanged)
        self.pageControl.currentPageIndicatorTintColor = .bostonRedLight
        self.pageControl.pageIndicatorTintColor = .inactiveGray
        self.reloadDataForCategoryType()
    }
    
    func reloadDataForCategoryType() {
    
        switch categoryType {
        case .income:
            self.pageControl.numberOfPages = 1
            self.pageControl.isHidden = true
            self.pageHeightConstraint.constant = 0
            self.chartsCollectionConstraint.constant = Config.collectionHeight
        case .expenses:
            self.pageControl.numberOfPages = 2
            self.pageControl.isHidden = false
            self.pageHeightConstraint.constant = Config.pageHeight
            self.chartsCollectionConstraint.constant = Config.tooltipCollectionHeight
        }
                
        layoutSubviews()
        self.chartsCollectionView.reloadData()
        self.delegate?.didShowChart(with: categoryType, and: viewModel, chartType: chartsTypes[pageControl.currentPage])
    }
    
    func registerCell() {
        let nib = UINib(nibName: "CategoriesChartCell", bundle: Bundle.module)
        self.chartsCollectionView.register(nib, forCellWithReuseIdentifier: "CategoriesChartCell")
    }
    
    @objc func pageControlSelectionAction(_ pageControl: UIPageControl) {
        self.chartsCollectionView.scrollToItem(at: IndexPath(item: pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
        self.delegate?.didShowChart(with: categoryType, and: viewModel, chartType: chartsTypes[pageControl.currentPage])
    }
}

extension ExpensesIncomeCategoriesCharts: UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension ExpensesIncomeCategoriesCharts: UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryType == .income ? 1 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CategoriesChartCell = collectionView.dequeue(type: CategoriesChartCell.self, at: indexPath)
        guard let viewModel = viewModel else { return cell }
        cell.load(with: viewModel, and: chartsTypes[indexPath.item])
        return cell
    }
}

extension ExpensesIncomeCategoriesCharts {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - width/2) / width) + 1)
        let shouldReload = page != pageControl.currentPage
        self.pageControl.currentPage = page
        if shouldReload {
            self.delegate?.didShowChart(with: self.categoryType, and: self.viewModel, chartType: self.chartsTypes[pageControl.currentPage])
            self.delegate?.categoryChartsDidSwipeWith(chartType: self.chartsTypes[pageControl.currentPage])
        }
    }
    
    func getCurrentChartType() -> ExpensesIncomeCategoriesChartType {
        return self.chartsTypes[self.pageControl.currentPage]
    }
}

extension ExpensesIncomeCategoriesCharts: InteractiveSectoredChartViewDelegate {
    
    func didSelect(sector: ChartSectorData?) {
        self.delegate?.didSelectCategory()
    }
}

extension ExpensesIncomeCategoriesCharts: ExpensesIncomeCategoriesChartsProtocol {
    func didUpdateData(_ viewModel: ExpensesIncomeCategoriesViewModel) {
        self.viewModel = viewModel
    }
}
