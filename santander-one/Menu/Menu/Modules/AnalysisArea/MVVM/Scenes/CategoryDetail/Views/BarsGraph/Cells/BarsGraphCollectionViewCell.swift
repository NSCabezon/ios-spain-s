//
//  DetailGraphCollectionViewCell.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 29/3/22.
//

import UIKit
import OpenCombine
import CoreFoundationLib

protocol GraphCollectionViewCellRepresentable {
    var barsData: [GraphColumnViewRepresentable] { get }
}

enum BarsGraphCollectionViewCellState: State {
    case didTapBar(_ info: (index: Int, mainAmount: Double, secondAmount: Double?))
    case didSelectCellIndex(_ index: Int)
}

final class BarsGraphCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var barsStackView: UIStackView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var stackviewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var stackviewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorBottomConstraint: NSLayoutConstraint!
    private var representable: BarsGraphViewRepresentable?
    private var subscriptions: Set<AnyCancellable> = []
    private var subject = PassthroughSubject<BarsGraphCollectionViewCellState, Never>()
    public var publisher: AnyPublisher<BarsGraphCollectionViewCellState, Never> {
        return subject.eraseToAnyPublisher()
    }
    private var graphType: GraphViewType? {
        return GraphViewType(rawValue: representable?.columnDataList.count ?? 0)
    }
    lazy var maxAmount: Double = {
        var maxAmount = representable?.columnDataList.compactMap { abs($0.mainAmount) }.max()
        var maxSecondaryAmount = representable?.columnDataList.compactMap { abs($0.secondaryAmount ?? 0) }.max()
        return [maxAmount, maxSecondaryAmount].compactMap { $0 }.max() ?? 0
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCellInfo(representable: BarsGraphViewRepresentable) {
        self.representable = representable
        self.barsStackView.removeAllArrangedSubviews()
        separatorView.backgroundColor = representable.darkColor
        makeGraph()
    }
    
    func selectBarAtIndex(_ index: Int) {
        if let bar = barsStackView.arrangedSubviews[index] as? GraphColumnView {
        bar.isSelected = true
        didTap(bar)
        }
    }
    
    func unselectBars() {
        let subviews = barsStackView.arrangedSubviews
        guard !(subviews.allSatisfy { ($0 as? GraphColumnView)?.isSelected == false }) else { return }
        for view in subviews {
            (view as? GraphColumnView)?.isSelected = false
        }
        setNeedsDisplay()
    }
}

private extension BarsGraphCollectionViewCell {
    var maxHeight: CGFloat {
        frame.height - (separatorBottomConstraint.constant - separatorView.frame.height) - 6.0
    }
    
    func getHeight(of amount: Double?, maxAmount: Double) -> CGFloat {
        guard let amount = amount, maxAmount != 0 else { return 5.0 }
        let amountPercentage = abs(amount) / abs(maxAmount)
        let total = maxHeight * amountPercentage
        return total < 5.0 ? 5.0 : total
    }
    
    func makeGraph() {
        guard let representable = representable, let type = graphType else { return }
        let colors = (representable.darkColor, representable.color)
        let max = self.maxAmount
        let columnViewRepresentableList = representable.columnDataList.map {
            GraphColumn(colors: colors,
                        datatext: $0.barText,
                        graphType: type,
                        mainHeight: getHeight(of: $0.mainAmount, maxAmount: maxAmount),
                        secondaryHeight: getHeight(of: $0.secondaryAmount, maxAmount: maxAmount))
        }
        columnViewRepresentableList.enumerated().forEach {
            let view = GraphColumnView()
            view.setInfo($1)
            view.setmainBarAccessibilityIdentifier("analysisBar\($0 + 1)",
                                                   labelIdentifier: "analysisMonth\($0 + 1)")
            barsStackView.addArrangedSubview(view)
            bindBar(view)
        }
        self.stackviewLeadingConstraint.constant = type.graphMargin
        self.stackviewTrailingConstraint.constant = type.graphMargin
        layoutSubviews()
    }
    
    func bindBar(_ bar: GraphColumnView) {
        bar.publisher
            .case { GraphColumnViewState.didTapColumn }
            .sink { [unowned self] columnView in
                didTap(columnView)
            }.store(in: &subscriptions)
    }
    
    func didTap(_ bar: GraphColumnView) {
        if bar.isSelected {
            if let index = barsStackView.arrangedSubviews.index(of: bar),
               let columnData = representable?.columnDataList[index],
               let relativeIndex = columnData.relativeIndex {
                subject.send(.didSelectCellIndex(index))
                subject.send(.didTapBar((relativeIndex,
                                         mainAmount: columnData.mainAmount ?? 0,
                                         secondAmount: columnData.secondaryAmount)))
                bar.setmainBarAccessibilityIdentifier("analysisBar\(index + 1)_selected",
                                                      labelIdentifier: "analysisMonth\(index + 1)_selected")
                bar.setSecondaryBarAccessibilityIdentifier("analysisBar_prevision")
            }
            for view in barsStackView.arrangedSubviews where view !== bar {
                (view as? GraphColumnView)?.isSelected = false
            }
            representable?.columnDataList.enumerated().forEach {
                if let columnView = $1 as? GraphColumnView, columnView !== bar {
                    columnView.setmainBarAccessibilityIdentifier("analysisBar\($0 + 1)",
                                                                 labelIdentifier: "analysisMonth\($0 + 1)")
                }
            }
            layoutIfNeeded()
        }
    }
    
    func setSelectedAccessibilityIdentifiers() {
        barsStackView.arrangedSubviews.enumerated().forEach {
            if let columnView = $1 as? GraphColumnView {
                
            }
        }
    }
}

struct GraphColumn {
    let colors: (dark: UIColor, normal: UIColor)
    let datatext: String
    let graphType: GraphViewType
    let mainHeight: CGFloat
    let secondaryHeight: CGFloat?
}

extension GraphColumn: GraphColumnViewRepresentable {
    var horizontalMargin: CGFloat {
        return graphType.barHorizontalMargin
    }
    
    var mainBarHeight: CGFloat {
        return mainHeight
    }
    
    var secondaryBarheight: CGFloat? {
        return secondaryHeight
    }
    
    var barWidth: CGFloat {
        return graphType.barWidth
    }
    
    var darkColor: UIColor {
        return colors.dark
    }
    
    var color: UIColor {
        return colors.normal
    }
    
    var labelText: String {
        return datatext
    }
}

enum GraphViewType: Int {
    case onebar = 1
    case twoBars = 2
    case threebars = 3
    case fourBars = 4
    case fiveBars = 5
    
    var barHorizontalMargin: CGFloat {
        switch self {
        case  .onebar, .twoBars, .threebars:
            return 24.0
        case .fourBars:
            return 20.0
        case .fiveBars:
            return 12.0
        }
    }
    
    var barWidth: CGFloat {
        switch self {
        case  .onebar, .twoBars, .threebars:
            return 48.0
        case .fourBars:
            return 40.0
        case .fiveBars:
            return 32.0
        }
    }
    
    var graphMargin: CGFloat {
        switch self {
        case .onebar:
            return 148.0 - self.barHorizontalMargin
        case .twoBars:
            return 100.0 - self.barHorizontalMargin
        case .threebars:
            return 52.0 - self.barHorizontalMargin
        case .fourBars:
            return 32.0 - self.barHorizontalMargin
        case .fiveBars:
            return 44.0 - self.barHorizontalMargin
        }
    }
}
