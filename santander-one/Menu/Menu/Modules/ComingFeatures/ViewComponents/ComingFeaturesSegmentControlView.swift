//
//  ComingFeaturesSegmentControlView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 21/02/2020.
//

import Foundation
import CoreFoundationLib
import UI

protocol ComingFeaturesSegmentControlViewDelegate: AnyObject {
    func didSelectedIndexChanged(_ index: Int)
}

class ComingFeaturesSegmentControlView: XibView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var lisboaSegmentedControl: LisboaSegmentedControl!
    weak var delegate: ComingFeaturesSegmentControlViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureSegmentedControl()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureSegmentedControl()
    }

    private func configureSegmentedControl() {
        let keys = ["shortly_tab_ideasToDo", "shortly_tab_ideasDone"]
        self.lisboaSegmentedControl.setup(with: keys)
        self.lisboaSegmentedControl.accessibilityIdentifier = "btnIdeas"
    }
    
    @IBAction private func segmentedControlIndexChanged(_ sender: Any) {
        delegate?.didSelectedIndexChanged(self.lisboaSegmentedControl.selectedSegmentIndex)
    }
}
