//
//  OperativeSummaryStandardFooterView.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 22/05/2020.
//

import UIKit
import UI
import CoreFoundationLib

public struct OperativeSummaryStandardFooterItemViewModel {
    
    public let image: UIImage?
    public let title: String
    public let action: () -> Void
    public let accessibilityIdentifier: String?
    
    public init(image: UIImage?,
                title: String,
                accessibilityIdentifier: String? = nil,
                action: @escaping () -> Void) {
        self.image = image
        self.title = title
        self.action = action
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    public init(imageKey: String,
                title: String,
                accessibilityIdentifier: String? = nil,
                action: @escaping () -> Void) {
        self.image = Assets.image(named: imageKey)
        self.title = title
        self.action = action
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

public final class OperativeSummaryStandardFooterView: XibView {
    
    // MARK: - Private attributes
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var labelSeparatorView: UIView!
    
    // MARK: - Public methods
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setupWithTitle(_ title: String, items: [OperativeSummaryStandardFooterItemViewModel]) {
        self.titleLabel.text = title
        items.forEach {
            let view = OperativeSummaryStandardFooterItemView($0)
            view.translatesAutoresizingMaskIntoConstraints = false
            self.stackView.addArrangedSubview(view)
            self.addSeparator()
        }
        // Add safe area extra bottom view
        if #available(iOS 11.0, *), let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
            let extraView = UIView(frame: .zero)
            extraView.backgroundColor = .blueAnthracita
            extraView.heightAnchor.constraint(equalToConstant: bottomPadding).isActive = true
            self.stackView.addArrangedSubview(extraView)
        }
    }
}

private extension OperativeSummaryStandardFooterView {
    
    func setupView() {
        self.backgroundColor = UIColor.blueAnthracita
        self.setContentHuggingPriority(UILayoutPriority(200), for: .vertical)
        self.labelSeparatorView.backgroundColor = .mediumSkyGray
        self.titleLabel.accessibilityIdentifier = AccessibilityOperativeSummary.summaryFooterTitle
    }
    
    func addSeparator() {
        let separator = UIView(frame: .zero)
        separator.backgroundColor = UIColor.mediumSkyGray
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.stackView.addArrangedSubview(separator)
    }
}
