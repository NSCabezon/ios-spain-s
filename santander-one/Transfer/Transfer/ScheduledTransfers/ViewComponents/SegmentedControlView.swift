//
//  SegmentedControlView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 05/02/2020.
//

import Foundation
import CoreFoundationLib
import UI

protocol SegmentedControlViewDelegate: AnyObject {
    func didSelectedIndexChanged(_ index: Int)
}

final class SegmentedControlView: UIView {
    @IBOutlet weak var lisboaSegmentedControl: LisboaSegmentedControl!
    var view: UIView?
    weak var delegate: SegmentedControlViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.xibSetup()
    }
    
    private func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.clear
        self.addSubview(view ?? UIView())
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    @IBAction private func segmentedControlIndexChanged(_ sender: Any) {
        delegate?.didSelectedIndexChanged(self.lisboaSegmentedControl.selectedSegmentIndex)
    }
    
    public func setSegmentedIndex(_ index: Int) {
        self.lisboaSegmentedControl.selectedSegmentIndex = index
    }
    
    public func getSelectedSegmentIndex() -> Int {
        return self.lisboaSegmentedControl.selectedSegmentIndex
    }
    
    public func setSegmentKeys(_ keys: [String], accessibilityIdentifiers: [String]? = nil) {
        self.lisboaSegmentedControl.setup(with: keys, accessibilityIdentifiers: accessibilityIdentifiers)
    }
}
