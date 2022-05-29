//
//  OperativeSummaryStandardHeaderView.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 22/05/2020.
//

import UIKit
import UI
import CoreFoundationLib

public struct OperativeSummaryStandardHeaderViewModel {
    
    public let image: String
    public let title: String
    public let description: String
    public let extraInfo: String?

    public init(image: String, title: String, description: String, extraInfo: String? = nil) {
        self.image = image
        self.title = title
        self.description = description
        self.extraInfo = extraInfo
    }
}

public final class OperativeSummaryStandardHeaderView: XibView {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var extraInfoLabel: UILabel!
    
    // MARK: - Public methods
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setContentHuggingPriority(UILayoutPriority(800), for: .vertical)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setContentHuggingPriority(UILayoutPriority(800), for: .vertical)
    }
    
    public func setupWithViewModel(_ viewModel: OperativeSummaryStandardHeaderViewModel) {
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.text = viewModel.description
        if let extraInfo = viewModel.extraInfo {
            let localizedConfig = LocalizedStylableTextConfiguration(
                font: .santander(family: .headline, type: .regular, size: 14),
                alignment: .center,
                lineHeightMultiple: 0.75,
                lineBreakMode: .none
            )
            self.extraInfoLabel.configureText(
                withKey: extraInfo,
                andConfiguration: localizedConfig
            )
            self.extraInfoLabel.numberOfLines = 0
            self.extraInfoLabel.textColor = .lisboaGray
        } else {
            self.extraInfoLabel.isHidden = true
        }
        self.imageView.image = Assets.image(named: viewModel.image)
        self.setAccesibilityIdentifiers()
    }
    
    private func setAccesibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityOperativeSummary.title
        self.descriptionLabel.accessibilityIdentifier = AccessibilityOperativeSummary.subtitle
        self.imageView.accessibilityIdentifier = AccessibilityOperativeSummary.ticImage
        self.extraInfoLabel.accessibilityIdentifier = AccessibilityOperativeSummary.extraInfo
    }
}

private extension OperativeSummaryStandardHeaderView {
    func setAccessibility() {
        titleLabel.accessibilityLabel = "\(titleLabel.text ?? ""). \(descriptionLabel.text ?? ""). \(extraInfoLabel.text ?? "")"
        descriptionLabel.accessibilityElementsHidden = true
        extraInfoLabel.accessibilityElementsHidden = true
    }
}
