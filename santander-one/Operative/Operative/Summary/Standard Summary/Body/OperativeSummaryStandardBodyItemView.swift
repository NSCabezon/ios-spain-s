//
//  OperativeSummaryStandardBodyItemView.swift
//  Alamofire
//
//  Created by José Carlos Estela Anguita on 25/05/2020.
//

import UIKit
import UI
import CoreFoundationLib

public class OperativeSummaryStandardBodyItemView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleImageView: UIImageView!
    @IBOutlet private weak var subTitle: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!

    public convenience init(_ viewModel: OperativeSummaryStandardBodyItemViewModel) {
        self.init(frame: .zero)
        self.titleLabel.text = viewModel.title
        self.subTitle.attributedText = viewModel.subTitle
        self.subTitle.numberOfLines = 0
        if let info = viewModel.info {
            self.infoLabel.attributedText = info
        } else {
            self.infoLabel.isHidden = true
        }
        self.setAccessibilityIdentifiers(viewModel.accessibilityIdentifier)
        guard let imageURL = viewModel.titleImageUrl else { return }
        self.titleImageView.loadImage(urlString: imageURL)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setupView() {
        self.titleLabel.setSantanderTextFont(size: 13, color: .grafite)
        self.subTitle.setSantanderTextFont(type: .bold, size: 14, color: .lisboaGray)
        self.infoLabel.setSantanderTextFont(type: .italic, size: 14, color: .lisboaGray)
    }
}

private extension OperativeSummaryStandardBodyItemView {
    func setAccessibilityIdentifiers(_ identifier: String?) {
        guard let identifier = identifier else { return }
        self.accessibilityIdentifier = identifier + "_view"
        self.titleLabel.accessibilityIdentifier = identifier + "_title"
        self.subTitle.accessibilityIdentifier = identifier + "_value"
        self.infoLabel.accessibilityIdentifier = identifier + "_bodyInfo"
    }
    
    func setAccessibility() {
        self.view?.subviews.setAccessibilityHidden(true)
        titleLabel.accessibilityElementsHidden = false
    }
}

extension OperativeSummaryStandardBodyItemView {
    public override var accessibilityElements: [Any]? {
        get {
            if let groupedAccessibilityElements = groupedAccessibilityElements {
                return groupedAccessibilityElements
            }
            let elements = self.groupElements([])
            groupedAccessibilityElements = elements
            return groupedAccessibilityElements
        }
        set {
            groupedAccessibilityElements = newValue
        }
    }

}
