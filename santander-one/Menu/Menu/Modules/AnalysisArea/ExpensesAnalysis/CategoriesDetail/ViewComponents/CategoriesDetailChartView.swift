//
//  CategoriesDetailChartView.swift
//  Menu
//
//  Created by David Gálvez Alonso on 09/07/2021.
//

import UI
import CoreFoundationLib

protocol CategoriesDetailChartViewDelegate: AnyObject {
    func didSelectedTimePeriod(_ timePeriodViewModel: TimePeriodTotalAmountFilterViewModel)
}

final class CategoriesDetailChartView: UIDesignableView {
    
    @IBOutlet private weak var totalDescriptionLabel: UILabel!
    @IBOutlet private weak var totalAmountLabel: UILabel!
    @IBOutlet private weak var forecastDescriptionLabel: UILabel!
    @IBOutlet private weak var forecastAmountLabel: UILabel!
    @IBOutlet private weak var totalContainerView: UIView!
    @IBOutlet private weak var chartCollectionView: UICollectionView!
    @IBOutlet private weak var loaderContainerView: UIView!
    @IBOutlet private weak var loaderImageView: UIImageView!
    
    private var viewModel: CategoriesDetailViewModel?
    private var selectedTimePeriodIndex: IndexPath = IndexPath(item: 0, section: 0)
    weak var delegate: CategoriesDetailChartViewDelegate?
    private let categoriesDetailChartViewCell = "CategoriesDetailChartViewCell"
    
    private enum Config {
        static let chartCellWidth: CGFloat = 100
    }
    
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override public func commonInit() {
        super.commonInit()
        self.setupViews()
        self.setupLabels()
    }
    
    func setViewModel(_ viewModel: CategoriesDetailViewModel) {
        let vModel: CategoriesDetailViewModel? = self.viewModel
        guard vModel?.timePeriodConfiguration.type != viewModel.timePeriodConfiguration.type else { return }
        self.viewModel = viewModel
        let amountDecorator = MoneyDecorator(viewModel.totalSpent, font: .santander(family: .text, type: .bold, size: 26), decimalFontSize: 20)
        self.totalAmountLabel.attributedText = amountDecorator.getFormatedCurrency()
        self.totalAmountLabel.textColor = viewModel.category.getCategoryColor().textColor
        self.forecastAmountLabel.text = viewModel.forecastAmount
        self.setupChart()
        self.chartCollectionView.reloadData()
        self.loaderContainerView.isHidden = true
    }
}

private extension CategoriesDetailChartView {
    func setupViews() {
        self.totalContainerView.layer.cornerRadius = 4
        self.totalContainerView.layer.borderWidth = 1
        self.totalContainerView.layer.borderColor = UIColor.lightSkyBlue.cgColor
        self.totalContainerView.addShadow(location: .bottom, color: .shadesWhite, opacity: 2, radius: 1, height: 2)
        self.registerCell()
        self.loaderImageView.isHidden = false
        self.loaderImageView.setPointsLoader()
    }
    
    func setupLabels() {
        self.totalDescriptionLabel.setSantanderTextFont(type: .regular, size: 14, color: .gray)
        self.totalDescriptionLabel.text = localized("analysis_label_totalSpent")
        self.totalAmountLabel.setSantanderTextFont(type: .bold, size: 26, color: .pinkDeep)
        self.forecastDescriptionLabel.setSantanderTextFont(type: .regular, size: 12, color: .grafite)
        self.forecastDescriptionLabel.text = localized("analysis_label_forecastOfSpending")
        self.forecastAmountLabel.setSantanderTextFont(type: .bold, size: 12, color: .bostonRed)
    }
    
    func setupChart() {
        guard let viewModel = self.viewModel else {
            return
        }
        self.selectedTimePeriodIndex = IndexPath(item: viewModel.totalTimePeriods()-1, section: 0)
        guard self.chartCollectionView.delegate == nil else {
            self.chartCollectionView.reloadData()
            self.scrollToLast()
            return
        }
        self.chartCollectionView.delegate = self
        self.chartCollectionView.dataSource = self
        self.scrollToLast()
    }
    
    func scrollToLast() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.chartCollectionView.scrollToItem(at: self.selectedTimePeriodIndex, at: .centeredHorizontally, animated: false)
        }
    }
    
    func registerCell() {
        let nib = UINib(nibName: categoriesDetailChartViewCell, bundle: Bundle.module)
        self.chartCollectionView.register(nib, forCellWithReuseIdentifier: categoriesDetailChartViewCell)
    }
    
    func selectCellFor(_ index: IndexPath) {
        if let cell = self.chartCollectionView.cellForItem(at: self.selectedTimePeriodIndex) as? CategoriesDetailChartViewCell {
            cell.deselectCell()
        }
        self.selectedTimePeriodIndex = index
        if let cell = self.chartCollectionView.cellForItem(at: self.selectedTimePeriodIndex) as? CategoriesDetailChartViewCell {
            cell.selectCell()
        }
    }
}

extension CategoriesDetailChartView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else {
            return 0
        }
        return viewModel.totalTimePeriods()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CategoriesDetailChartViewCell = collectionView.dequeue(type: CategoriesDetailChartViewCell.self, at: indexPath)
        guard let viewModel = self.viewModel,
              let periodViewModel = viewModel.totalAmountTimePeriods[safe: indexPath.item] else { return cell }
        cell.color = viewModel.category.getCategoryColor().sector
        cell.set(viewModel: periodViewModel,
                 maxValue: viewModel.totalSpentMaxValue,
                 forecastValue: viewModel.forecastAmountValue)
        indexPath.item == self.selectedTimePeriodIndex.item ? cell.selectCell() : cell.deselectCell()
        return cell
    }
}

extension CategoriesDetailChartView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = self.viewModel?.totalAmountTimePeriods[safe: indexPath.item] else { return }
        self.selectCellFor(indexPath)
        self.delegate?.didSelectedTimePeriod(viewModel)
    }
}

extension CategoriesDetailChartView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Config.chartCellWidth, height: collectionView.frame.height)
    }
}
