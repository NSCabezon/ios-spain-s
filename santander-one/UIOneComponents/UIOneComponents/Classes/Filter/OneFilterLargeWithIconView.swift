//
//  OneFilterLargeWithIconView.swift
//  UIOneComponents
//
//  Created by Carlos Monfort Gómez on 24/9/21.
//

import UI
import CoreFoundationLib

public protocol OneFilterLargeWithIconDelegate: AnyObject {
    func didSelectOneSegmentedItem(_ index: Int)
}

public final class OneFilterLargeWithIconView: XibView {
    @IBOutlet private weak var oneFilter: OneFilterView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var containerView: UIView!
    weak var delegate: OneFilterLargeWithIconDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setViewModel(_ viewModel: OneFilterLargeWithIconViewModel) {
        self.oneFilter.setupSimple(with: ["", ""])
        self.setSegmentedViews(viewModel.segmentViewModels)
        self.updateSegmentedItems(0)
    }
}

private extension OneFilterLargeWithIconView {
    func setupView() {
        self.backgroundColor = .clear
        self.updateSegmentedItems(0)
    }
    
    func updateSegmentedItems(_ selectedIndex: Int) {
        self.oneFilter.selectedSegmentIndex = selectedIndex
        let segmentedItems = self.stackView.subviews.map { $0 as? OneSegmentedItemView }
        for (index, item) in segmentedItems.enumerated() {
            item?.setSegmentedStyle(self.oneFilter.selectedSegmentIndex == index)
        }
    }
    
    func setSegmentedViews(_ viewModels: [OneSegmentedItemViewModel]) {
        viewModels.forEach {
            let segmentView = OneSegmentedItemView()
            segmentView.setViewModel($0)
            segmentView.delegate = self
            self.stackView.addArrangedSubview(segmentView)
        }
    }
    
    func setAccessibilityIdentifier() {
        self.oneFilter.accessibilityIdentifier = AccessibilityOneComponents.oneFilter
    }
    
    func didTapOnOneFilter(_ index: Int) {
        self.updateSegmentedItems(index)
        self.delegate?.didSelectOneSegmentedItem(index)
    }
}

extension OneFilterLargeWithIconView: OneSegmentedItemDelegate {
    func didSelectOneSegmentedItem(_ index: Int) {
        self.didTapOnOneFilter(index)
    }
}
