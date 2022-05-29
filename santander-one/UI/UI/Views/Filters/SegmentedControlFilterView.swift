//
//  SegmentedControl.swift
//  UI
//
//  Created by Tania Castellano Brasero on 31/01/2020.
//

import UIKit
import CoreFoundationLib

public class SegmentedControlFilterView: UIView {
    private var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentedControlContentView: UIView!
    @IBOutlet weak var segmentedControlView: LisboaSegmentedControl!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    private func setupView() {
        self.xibSetup()
        self.setAppearance()
        self.setAccessibilityIdentifiers()
    }

    private func xibSetup() {
        self.backgroundColor = .clear
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.backgroundColor = UIColor.bg
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }

    public func setAppearance() {
        self.view.backgroundColor = .white
        self.titleLabel.textColor = UIColor.lisboaGray
        self.titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 16)
    }
    
    public func configure(title: String, types: [String], itemSelected: Int) {
        self.titleLabel.text = title
        self.segmentedControlView.setup(with: types, accessibilityIdentifiers: [AccessibilityAccountFilterSegmenteds.tabAll, AccessibilityAccountFilterSegmenteds.tabExpenses, AccessibilityAccountFilterSegmenteds.tabDeposit])
        self.segmentedControlView.selectedSegmentIndex = itemSelected
    }
    
    public func getSelectedIndex() -> Int {
        return self.segmentedControlView.selectedSegmentIndex
    }
    
    public func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityAccountFilter.segmentedTitleLabel
        self.segmentedControlView.accessibilityIdentifier = AccessibilityAccountFilter.segmentedControlViewContent
    }
}
