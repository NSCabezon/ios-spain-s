//
//  FinancingDistributionView.swift
//  Pie Chart View
//
//  Created by Boris Chirino Fernandez on 28/08/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UI
import CoreFoundationLib

protocol FinancingDistributionDelegate: AnyObject {
    func updateTableViewHeight(_ height: CGFloat)
}

final class FinancingDistributionView: UIDesignableView {
    @IBOutlet weak private var sectorChartView: SectoredChartView!
    @IBOutlet weak private var productsTableView: AutoSizeTableView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var separatorView: UIView!
    @IBOutlet weak private var tableTopHeight: NSLayoutConstraint!
    weak var delegate: FinancingDistributionDelegate?
    private var productsDataSource = FinancingDistributionDataSource()
    struct ComponentSizes {
        static let cellHeight: CGFloat = 60
        static let topChartHeight: CGFloat = 80
        static let bottomChartHeight: CGFloat = 50
    }
    public var viewState: ViewState<FinanceDistributionViewModel> = .loading {
        didSet {
            switch viewState {
            case let .filled(viewModel):
                updateViewModel(viewModel: viewModel)
                self.updateComponentHeight(viewModel)
                productsTableView.reloadData()
            case .empty:
                delegate?.updateTableViewHeight(0)
            default:
                break
            }
        }
    }
    
    override func getBundleName() -> String {
        "Menu"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLabels()
        setupChartAppearance()
        setupTableView()
        setupIdentifiers()
    }
}

private extension FinancingDistributionView {
    func setupChartAppearance() {
        sectorChartView.textPositionOffset = 0.85
        sectorChartView.innerRadioDelta = 1.5
        sectorChartView.outerRadioDelta = 1.3
        sectorChartView.sectorLabelFont = .santander(family: .text, type: .bold, size: 14)
    }
    
    func setupTableView() {
        let nib = UINib(nibName: FinancingDistributionProductCell.nibName, bundle: .module)
        self.productsTableView.register(nib, forCellReuseIdentifier: FinancingDistributionProductCell.cellIdentifier)
        self.productsTableView.rowHeight = UITableView.automaticDimension
        self.productsTableView.estimatedRowHeight = 60
        self.productsTableView.isScrollEnabled = false
        self.productsTableView.allowsSelection = false
        self.productsTableView.dataSource = self.productsDataSource
        self.productsTableView.separatorStyle = .none
        self.productsTableView.accessibilityIdentifier = AccessibilityFinancingDistribution.productsList
        self.separatorView.backgroundColor = .mediumSkyGray
    }
    
    func setupLabels() {
        self.titleLabel.font = .santander(family: .text, type: .light, size: 22.0)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.configureText(withLocalizedString: localized("financing_title_distribution"))
    }
    
    func updateViewModel(viewModel: FinanceDistributionViewModel) {
        // update graph
        let sectors: [ChartSectorData]? = viewModel.graphData()?.compactMap({
            let number =  NSDecimalNumber(decimal: $0.value).doubleValue
            let textColor: UIColor = $0.type == .creditCards ? .white : .lisboaGray
            return ChartSectorData(
                value: number,
                iconName: $0.type.iconName,
                colors: ChartSectorData.Colors(sector: $0.type.sectorColor, textColor: textColor))
            })
        
        if let sectorsData = sectors, let centerText = viewModel.centerText {
            sectorChartView.sectors = sectorsData
            sectorChartView.centerAttributedTextTop = centerText
        }
        
        // update tableView
        productsDataSource.state = viewState
    }
    
    func setupIdentifiers() {
        sectorChartView.accessibilityIdentifier = "financingViewGraphicYourFinancing"
    }
    
    func updateComponentHeight(_ viewModel: FinanceDistributionViewModel) {
        self.tableTopHeight.constant = CGFloat.greatestFiniteMagnitude
        self.productsTableView.invalidateIntrinsicContentSize()
        self.productsTableView.layoutIfNeeded()
        self.productsTableView.reloadData()
        let tableHeight = self.productsTableView.contentSize.height
        let chartHeight = ComponentSizes.topChartHeight + sectorChartView.frame.height + ComponentSizes.bottomChartHeight
        self.tableTopHeight.constant = tableHeight
        let height = tableHeight + chartHeight
        delegate?.updateTableViewHeight(height)
    }
}
