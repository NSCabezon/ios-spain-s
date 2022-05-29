//
//  OtherSpendsTableViewCell.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 23/1/22.
//

import UIKit
import UIOneComponents
import OpenCombine
import CoreFoundationLib

enum OtherSpendsTableViewCellState: State {
    case didTapExpanded
    case didSelectCategory(CategoryRepresentable)
}

class OtherSpendsTableViewCell: UITableViewCell {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var otherSpendsView: OtherSpendsView!
    private var subscriptions: Set<AnyCancellable> = []
    private var subject = PassthroughSubject<OtherSpendsTableViewCellState, Never>()
    public lazy var publisher: AnyPublisher<OtherSpendsTableViewCellState, Never> = {
        return subject.eraseToAnyPublisher()
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setAppearance()
        bindViews()
    }

    func setCellInfo(_ info: [CategoryRepresentable], isExpanded: Bool) {
        otherSpendsView.setInfo(info, isExpanded: isExpanded)
        setAccessibilityIdentifiers()
    }
    
    func setExpanedCategories(isExpanded: Bool) {
        containerView.accessibilityValue = isExpanded ? localized("voiceover_collapseHiddenCategories") : localized("voiceover_viewHiddenCategories")
        otherSpendsView.setExpanedCategories(isExpanded: isExpanded)
    }
}

private extension OtherSpendsTableViewCell {
    func setAppearance() {
        containerView.backgroundColor = .oneWhite
        containerView.setOneCornerRadius(type: .oneShRadius4)
        containerView.clipsToBounds = true
        containerView.setOneShadows(type: .oneShadowSmall)
        containerView.layer.masksToBounds = false
    }
    
    func bindViews() {
        bindDidTapExpanded()
        bindDidSelectCategory()
    }
    
    func bindDidTapExpanded() {
        otherSpendsView
            .publisher
            .case(OtherSpendsViewState.didTapExpanded)
            .sink { [unowned self] _ in
                self.subject.send(.didTapExpanded)
            }.store(in: &subscriptions)
    }
    
    func bindDidSelectCategory() {
        otherSpendsView
            .publisher
            .case { OtherSpendsViewState.didSelectCategory }
            .sink { [unowned self] category in
                self.subject.send(.didSelectCategory(category))
            }.store(in: &subscriptions)
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = "\(AnalysisAreaAccessibility.analysisCardCategoriesList)_\(ExpensesIncomeCategoryType.otherExpenses.rawValue)"
    }
}
