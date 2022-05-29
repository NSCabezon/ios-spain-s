//
//  ChartCollectionViewCell.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 26/1/22.
//

import UIKit
import UI
import UIOneComponents
import OpenCombine
import CoreFoundationLib
import CoreDomain

protocol ChartCollectionViewCellRepresentable: InteractiveSectoredPieChartViewRepresentable {
    var categorization: AnalysisAreaCategorization { get }
    var categories: [CategoryRepresentable] { get }
    var tooltipLabelTextKey: String? { get }
    var chartCenterIconKey: String { get }
    var chartCenterText: String { get }
}

enum ChartCollectionViewCellState: State {
    case didSelectSector(sector: CategoryRepresentable)
    case didTapToolTip
}

final class ChartCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var interactiveChart: InteractiveSectoredPieChartView!
    @IBOutlet private weak var tooltipImageView: UIImageView!
    @IBOutlet private weak var tooltipLabel: UILabel!
    private var subject = PassthroughSubject<ChartCollectionViewCellState, Never>()
    public var publisher: AnyPublisher<ChartCollectionViewCellState, Never> {
        return subject.eraseToAnyPublisher()
    }
    private var subscriptions: Set<AnyCancellable> = []
    var isVisible: Bool = true {
        didSet {
            setAppearance()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bindChart()
        setAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        interactiveChart.reset()
    }
    
    func setCellInfo(_ data: ChartCollectionViewCellRepresentable, isVisible: Bool) {
        self.isVisible = isVisible
        let categories = data.categories
        let total = categories.compactMap { $0.amount.value }.reduce(0.0, +)
        let amount = AmountEntity(value: total, currency: categories.first?.currency.currencyType ?? .eur)
        interactiveChart.reset()
        interactiveChart.setChartInfo(data)
        handleTooltip(data.tooltipLabelTextKey)
        setAccessibilityIdentifiers(categorization: data.categorization)
        setAccessibility { [weak self] in
            self?.setAccessbilityInfo(data: data)
        }
        interactiveChart.build()
        layoutSubviews()
    }
}

private extension ChartCollectionViewCell {
    func setAppearance() {
        interactiveChart.backgroundColor = isVisible ? .oneWhite : .oneSkyGray
        containerView.backgroundColor = isVisible ? .oneWhite : .oneSkyGray
        tooltipImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTooltip)))
        tooltipImageView.isUserInteractionEnabled = true
        tooltipImageView.image = Assets.image(named: "oneIcnHelp")
        tooltipLabel.font = .typography(fontName: .oneB300Regular)
        tooltipLabel.numberOfLines = 2
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = isVisible ? UIColor.oneMediumSkyGray.cgColor : UIColor.oneBrownGray.cgColor
        containerView.clipsToBounds = true
    }
    
    @objc func didTapTooltip() {
        subject.send(.didTapToolTip)
    }
    
    func bindChart() {
        interactiveChart
            .publisher
            .case { InteractiveSectoredPieChartViewState.sectorSelected }
            .sink { [unowned self] sector in
                subject.send(.didSelectSector(sector: sector))
            }.store(in: &subscriptions)
    }
    
    func handleTooltip(_ key: String?) {
        let labelKey: String = key ?? ""
        [tooltipLabel, tooltipImageView]
            .forEach { $0?.isHidden = labelKey == "" }
        tooltipLabel.text = localized(labelKey)
    }
    
    func setAccessbilityInfo(data: ChartCollectionViewCellRepresentable) {
        interactiveChart.isAccessibilityElement = true
        interactiveChart.isUserInteractionEnabled = false
        interactiveChart.accessibilityLabel = getChartAccessibilitylabel(data.categorization, categories: data.categories)
        tooltipLabel.accessibilityLabel = getTooltipImageAccessibilityLabel(data.categorization)
        tooltipLabel.accessibilityValue = tooltipLabel.text
        tooltipLabel.accessibilityTraits = .button
        tooltipLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTooltip)))
        tooltipLabel.isUserInteractionEnabled = true
        accessibilityElements = [interactiveChart, tooltipLabel].compactMap {$0}
    }
    
    func setAccessibilityIdentifiers(categorization: AnalysisAreaCategorization) {
        tooltipImageView.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
        tooltipLabel.accessibilityIdentifier = "\(categorization.prefixKey)\(AnalysisAreaAccessibility.chartTooltipLabel)"
        tooltipImageView.accessibilityIdentifier = "\(categorization.prefixKey)\(AnalysisAreaAccessibility.chartTooltipImage)"
        self.accessibilityIdentifier = "\(categorization.prefixKey)\(AnalysisAreaAccessibility.chartCollectionCell)"
    }
    
    func getChartAccessibilitylabel(_ categorization: AnalysisAreaCategorization, categories: [CategoryRepresentable]) -> String {
        let total = categories.compactMap { $0.amount.value }.reduce(0.0, +)
        let amount = AmountEntity(value: total, currency: categories.first?.currency.currencyType ?? .eur)
        let centerAmount = amount.getFormattedAmountAsMillions(withDecimals: 2)
        switch categorization.rawValue {
        case 0: return localized("voiceover_donutChartExpenses", [StringPlaceholder(.value, centerAmount)]).text
        case 1: return localized("voiceover_donutChartPayments", [StringPlaceholder(.value, centerAmount)]).text
        case 2: return localized("voiceover_donutChartIncomes", [StringPlaceholder(.value, centerAmount)]).text
        default: return ""
        }
    }
    
    func getTooltipImageAccessibilityLabel(_ categorization: AnalysisAreaCategorization) -> String {
        switch categorization.rawValue {
        case 0: return localized("voiceover_expensesHelpInfo")
        case 1: return localized("voiceover_paymentsHelpInfo")
        default: return ""
        }
    }
}

extension ChartCollectionViewCell: AccessibilityCapable {}
