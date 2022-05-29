//
//  ChartCellRepresentable.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 2/3/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain

struct ChartCellRepresentation {
    let tooltipLabelKey: String?
    let chartData: [CategoryRepresentable]
}

extension ChartCellRepresentation: ChartCollectionViewCellRepresentable {
    var categorization: AnalysisAreaCategorization {
        chartData.first?.categorization ?? .expenses
    }
    
    var chartCenterIconKey: String {
        let type = chartData.first?.categorization
        return type?.iconKey ?? "imgGasoline"
    }
    
    var chartCenterText: String {
        return localized("analysis_label_total").text
    }
    
    var categories: [CategoryRepresentable] {
        return chartData
    }
    
    var tooltipLabelTextKey: String? {
        return tooltipLabelKey
    }
}

extension ChartCellRepresentation: InteractiveSectoredPieChartViewRepresentable {
    var graphDiameter: CGFloat {
        return 212.0
    }
    
    var innerCircleDiameter: CGFloat {
        return 156.0
    }
    
    var archWidth: CGFloat {
        return 28.0
    }
    
    var iconSize: CGFloat {
        return 32.0
    }
    
    var centerIconKey: String {
        return chartCenterIconKey
    }
    
    var centerTitleText: String {
        let total = categories.compactMap { $0.amount.value }.reduce(0.0, +)
        let amount = AmountEntity(value: total, currency: categories.first?.currency.currencyType ?? .eur)
        return amount.getFormattedValueOrEmptyUI(withDecimals: 2, truncateDecimalIfZero: true)
    }
    
    var centerSubtitleText: String {
        return chartCenterText
    }
    
    var amountBackgroundColor: UIColor {
        return .clear
    }
    
    var graphIndentifierKey: String {
        categorization.prefixKey
    }
}
