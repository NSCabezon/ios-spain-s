//
//  FHFilterCollectionViewCell.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 11/4/22.
//

import UI
import UIKit
import CoreDomain
import CoreFoundationLib
import OpenCombine

enum FHFilterCollectionViewCellState: State {
    case idle
    case selectUnselectSubcategory(_ subcategory: GetFinancialHealthSubcategoryRepresentable, _ isSelected: Bool)
}

final class FHFilterCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var filterTitle: UILabel!
    @IBOutlet private weak var filterSubtitle: UILabel!
    @IBOutlet private weak var selectedIndicator: UIImageView!
    private var representable: GetFinancialHealthSubcategoryRepresentable?
    private var period: PeriodSelectorRepresentable?
    private let stateSubject = CurrentValueSubject<FHFilterCollectionViewCellState, Never>(.idle)
    var publisher: AnyPublisher<FHFilterCollectionViewCellState, Never> {
        return stateSubject.eraseToAnyPublisher()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setAppearance()
        setAccessibilityIdentifiers()
    }
    
    override var isSelected: Bool {
        didSet {
            setContainerAppearence()
        }
    }

    func configureWith(_ representable: GetFinancialHealthSubcategoryRepresentable, periodSelected: PeriodSelectorRepresentable) {
        self.representable = representable
        self.period = periodSelected
        configureViews()
    }
}

private extension FHFilterCollectionViewCell {
    func configureViews() {
        configureLabels()
    }
    
    func configureLabels() {
        guard let info = representable else { return }
        filterTitle.text = "\(localized(info.subcategory?.literalKey ?? ""))"
        filterSubtitle.text = AmountEntity(value: 0, currencyCode: info.totalAmount?.currencyRepresentable?.currencyCode ?? "").value?.toStringWithCurrency()
        let periodSelected = info.periods?.first {
            $0.periodDateFrom == period?.startPeriod && $0.periodDateTo == period?.endPeriod
        }
        guard let periodAmount = periodSelected?.periodAmount else { return }
        filterSubtitle.text = AmountEntity(periodAmount).value?.toStringWithCurrency()
    }
    
    func setAppearance() {
        setContainerAppearence()
        setLabelsAppearence()
        setSelectedIndicator()
    }
    
    func setContainerAppearence() {
        containerView.setOneCornerRadius(type: .oneShRadius8)
        containerView.backgroundColor = isSelected ? .oneTurquoiseTransparent : .oneWhite
        containerView.layer.borderColor = UIColor.oneMediumSkyGray.cgColor
        containerView.layer.borderWidth = isSelected ? 0 : 1
        selectedIndicator.isHidden = isSelected.isFalse
    }
    
    func setLabelsAppearence() {
        filterTitle.font = .typography(fontName: .oneB300Bold)
        filterSubtitle.font = .typography(fontName: .oneB300Regular)
    }
    
    func setSelectedIndicator() {
        selectedIndicator.image = Assets.image(named: "icnCheckOvalGreen")?.withRenderingMode(.alwaysOriginal)
        selectedIndicator.contentMode = .scaleAspectFit
    }
    
    func setAccessibilityIdentifiers() {
    }
} 
