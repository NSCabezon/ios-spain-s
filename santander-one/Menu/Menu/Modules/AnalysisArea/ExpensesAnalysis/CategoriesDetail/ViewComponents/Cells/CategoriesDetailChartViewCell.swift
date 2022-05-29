//
//  CategoriesDetailChartViewCell.swift
//  Menu
//
//  Created by Mario Rosales Maillo on 12/7/21.
//

import Foundation

final class CategoriesDetailChartViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var bottomBackgroundView: UIView!
    @IBOutlet private weak var selectedView: UIView!
    @IBOutlet private weak var valueView: UIView!
    @IBOutlet private weak var forecastValueView: UIView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var valueViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var forecastValueViewHeightConstraint: NSLayoutConstraint!
    
    public var color: UIColor = .bostonRed

    private enum Config {
        static let minPeriodHeight: Decimal = 5.0
        static let maxPeriodHeight: Decimal = 70.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.forecastValueView.backgroundColor = .clear
        self.deselectCell()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func set(viewModel: TimePeriodTotalAmountFilterViewModel, maxValue: Decimal, forecastValue: Decimal) {
        self.dateLabel.text = viewModel.period
        self.amountLabel.text = viewModel.amount
        let height = (viewModel.amountValue * Config.maxPeriodHeight) / maxValue
        self.valueViewHeightConstraint.constant = Double(truncating: height as NSNumber).toCGFloat
        self.valueView.setNeedsLayout()
        self.valueView.layoutIfNeeded()
        self.setupStyle()
        if viewModel.showForecast {
            self.setupForecast(with: maxValue, and: forecastValue)
        } else {
            self.forecastValueView.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        }
    }
    
    func selectCell() {
        self.selectedView.isHidden = false
        self.dateLabel.font = .santander(family: .text, type: .bold, size: 12)
        self.amountLabel.font = .santander(family: .text, type: .bold, size: 12)
    }
    
    func deselectCell() {
        self.selectedView.isHidden = true
        self.dateLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.amountLabel.font = .santander(family: .text, type: .regular, size: 12)
    }
}

private extension CategoriesDetailChartViewCell {
    func setupView() {
        self.deselectCell()
        self.bottomBackgroundView.backgroundColor =  .skyGray
        self.bottomBackgroundView.layer.cornerRadius = 4
        self.selectedView.layer.cornerRadius = 4
        self.selectedView.clipsToBounds = true
        self.selectedView.backgroundColor = .white
        self.selectedView.layer.masksToBounds = false
        self.selectedView.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.selectedView.layer.shadowColor = UIColor.black.cgColor
        self.selectedView.layer.shadowOpacity = 0.2
        self.selectedView.layer.shadowRadius = 2
        self.valueView.clipsToBounds = true
        self.dateLabel.textColor = .lisboaGray
        self.amountLabel.textColor = .lisboaGray
    }
    
    func setupStyle() {
        self.valueView.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        self.valueView.applyGradientBackground(colors: [color, color.withAlphaComponent(0.3)])
        self.valueView.roundCorners(corners: [.topLeft, .topRight], radius: 4.0)
    }
    
    func setupForecast(with maxValue: Decimal, and forecastValue: Decimal) {
        let forecastHeight = (forecastValue * Config.maxPeriodHeight) / maxValue
        self.forecastValueViewHeightConstraint.constant = Double(truncating: forecastHeight as NSNumber).toCGFloat
        self.forecastValueView.setNeedsLayout()
        self.forecastValueView.layoutIfNeeded()
        self.forecastValueView.backgroundColor = color.withAlphaComponent(0.1)
        self.forecastValueView.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        self.forecastValueView.addLineDashedStroke(pattern: [2, 2], radius: 4, color: color)
    }
}
