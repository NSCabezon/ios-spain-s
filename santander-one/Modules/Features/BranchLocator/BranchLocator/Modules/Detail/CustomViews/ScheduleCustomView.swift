//
//  ScheduleCustomView.swift
//  BranchLocator
//
//  Created by Daniel Rincon on 01/07/2019.
//

import UIKit

class ScheduleCustomView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var detailStackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle(for: ScheduleCustomView.self).branchLocatorBundle?.loadNibNamed("ScheduleCustomView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    // MARK: - Configure functions
    
    func setupHours(hours: [String]) {
        var label: UILabel
        for hour in hours {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: detailStackView.frame.width, height: titleLabel.frame.height))
            label.text = "\(hour)"
            label.font = DetailCardCellAndViewThemeFont.bodyText.value
            label.textColor = DetailCardCellAndViewThemeColor.bodyText.value
            detailStackView.addArrangedSubview(label)
        }
        
    }
}
