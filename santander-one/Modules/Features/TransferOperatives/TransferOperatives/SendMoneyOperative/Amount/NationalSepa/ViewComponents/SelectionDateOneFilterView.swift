//
//  SelectionDateOneFilterView.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 30/9/21.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol SelectionDateOneFilterDelegate: AnyObject {
    func didSelecteOneFilterSegment(_ index: Int)
}

final class SelectionDateOneFilterView: XibView {
    @IBOutlet private weak var descriptionOneLabel: OneLabelView!
    @IBOutlet private weak var oneFilter: OneFilterView!
    weak var delegate: SelectionDateOneFilterDelegate?
    private var viewModel: SelectionDateOneFilterViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: SelectionDateOneFilterViewModel) {
        self.viewModel = viewModel
        self.descriptionOneLabel.setupViewModel(viewModel.oneLabelViewModel)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
        self.oneFilter.setupSimple(with: viewModel.options, withIndex: viewModel.selectedIndex)
        self.oneFilter.addTarget(self, action: #selector(didChangeSegment(sender:)), for: .valueChanged)
    }
}

private extension SelectionDateOneFilterView {
    func setupView() {
        self.setAccessibilityIdentifiers()
    }
    
    @objc func didChangeSegment(sender: OneFilterView) {
        self.delegate?.didSelecteOneFilterSegment(sender.selectedSegmentIndex)
    }
    
    func setAccessibilityIdentifiers() {
        self.oneFilter.accessibilityIdentifier = AccessibilitySendMoneyAmount.selectionDateOneFilter
        self.descriptionOneLabel.setAccessibilitySuffix(AccessibilitySendMoneyAmount.periodicitySuffix)
    }
    
    func setAccessibilityInfo() {
        guard let viewModel = self.viewModel else { return }
        self.descriptionOneLabel.setAccessibilityLabel(accessibilityLabel: localized("voiceover_selectOptionSendMoney", [.init(.number, "\(viewModel.options.count)")]).text)
    }
}

extension SelectionDateOneFilterView: AccessibilityCapable {}
