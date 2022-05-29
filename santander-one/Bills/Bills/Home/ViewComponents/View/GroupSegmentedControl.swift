//
//  GroupSegmentedControl.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/24/20.
//

import Foundation
import UI

protocol GroupSegmentedControlDelegate: AnyObject {
    func didSegmentIndexChanged(_ index: Int)
}

final class GroupSegmentedControl: UIView {
    private var segmentedControl = LisboaSegmentedControl(frame: .zero)
    private weak var delegate: GroupSegmentedControlDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.appearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.appearance()
    }
    
    func setDelegate(delegate: GroupSegmentedControlDelegate) {
        self.delegate = delegate
    }
    
    @objc private func didValueChange() {
        let index = self.segmentedControl.selectedSegmentIndex
        self.delegate?.didSegmentIndexChanged(index)
    }
}

private extension GroupSegmentedControl {
    func appearance() {
        self.backgroundColor = .white
        self.addSubview(segmentedControl)
        self.addSegmentedSections()
        self.addConstraints()
        self.segmentedControl.accessibilityIdentifier = "areaTab"
        self.segmentedControl.addTarget(self, action: #selector(didValueChange), for: .valueChanged)
    }
    
    func addSegmentedSections() {
        self.segmentedControl.setup(with: [
            "generic_label_date",
            "receiptsAndTaxes_tab_issuing",
            "receiptsAndTaxes_tab_product"
        ])
    }
    
    func addConstraints() {
        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.segmentedControl.heightAnchor.constraint(equalToConstant: 40),
            self.segmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            self.segmentedControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            self.segmentedControl.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            self.segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11)
            ]
        )
    }
}
