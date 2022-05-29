//
//  SortDateSegmented.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 7/1/20.
//
import UI
import Foundation
import CoreFoundationLib

protocol SortDateSegmentedDelegate: AnyObject {
    func didSelectSortByDate(_ date: Date)
}

final class SortDateSegmented: UIView {
    let segmentedControl = LisboaSegmentedControl(frame: .zero)
    weak var delegate: SortDateSegmentedDelegate?
    var dates = [Date]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setDates(_ dates: [Date]) {
        self.dates = dates
        self.segmentedControl.setup(with: dates.map { $0.monthLocalizedKey() })
        guard let selected = dates.last else { return }
        self.segmentedControl.selectedSegmentIndex = dates.count - 1
        self.delegate?.didSelectSortByDate(selected)
    }
}

private extension SortDateSegmented {
    func setupView() {
        self.segmentedControl.addTarget(self, action: #selector(didValueChange), for: .valueChanged)
        self.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            segmentedControl.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -14),
            segmentedControl.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            segmentedControl.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    @objc private func didValueChange() {
        let index = self.segmentedControl.selectedSegmentIndex
        self.delegate?.didSelectSortByDate(dates[index])
    }
}
