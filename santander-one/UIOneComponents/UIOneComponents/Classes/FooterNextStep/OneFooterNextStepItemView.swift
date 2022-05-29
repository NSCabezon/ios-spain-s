//
//  OneOperativeSummaryFooterNextStepView.swift
//  UIOneComponents
//
//  Created by Daniel Gómez Barroso on 13/10/21.
//

import UI
import CoreFoundationLib

public final class OneFooterNextStepItemView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var separatorView: UIView!
    private var action: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public init(with viewModel: OneFooterNextStepItemViewModel) {
        super.init(frame: .zero)
        self.setupView()
        self.setViewModel(viewModel)
    }
    
    public func setViewModel(_ viewModel: OneFooterNextStepItemViewModel) {
        self.titleLabel.text = localized(viewModel.titleKey)
        self.imageView.image = Assets.image(named: viewModel.imageName)
        self.imageView.image?.accessibilityIdentifier = viewModel.imageName
        self.action = viewModel.action
        self.setAccessibilityIdentifiers(viewModel.accessibilitySuffix)
    }
    
    public func setSeparatorHidden(_ isHidden: Bool) {
        self.separatorView.isHidden = isHidden
    }
}

private extension OneFooterNextStepItemView {
    func setupView() {
        self.separatorView.backgroundColor = .oneMediumSkyGray
        self.separatorView.alpha = 0.4
        self.titleLabel.textColor = .oneWhite
        self.titleLabel.font = .typography(fontName: .oneB300Regular)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performAction)))
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.imageView.accessibilityIdentifier = AccessibilityOneComponents.oneFooterOperativeItemIcn + (suffix ?? "")
        self.titleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneFooterOperativeItemTitle + (suffix ?? "")
    }
    
    @objc func performAction() {
        self.action?()
    }
}
