//
//  OneOperativeSummaryFooterView.swift
//  UIOneComponents
//
//  Created by Daniel Gómez Barroso on 13/10/21.
//

import UI
import CoreFoundationLib

public final class OneFooterNextStepView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    
    private var viewModel: OneFooterNextStepViewModel?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public init(with viewModel: OneFooterNextStepViewModel) {
        super.init(frame: .zero)
        self.setupView()
        self.setViewModel(viewModel)
    }
    
    public func setViewModel(_ viewModel: OneFooterNextStepViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = localized(viewModel.titleKey)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
        for (index, model) in viewModel.elements.enumerated() {
            let oneFooterView = OneFooterNextStepItemView(with: model)
            self.setAccessibility {
                self.setAccessibilityForFooterViewItem(footerView: oneFooterView, model: model, index: index)
            }
            self.stackView.addArrangedSubview(oneFooterView)
        }
        guard let view = self.stackView.arrangedSubviews.last as? OneFooterNextStepItemView else { return }
        view.setSeparatorHidden(true)
    }
}

private extension OneFooterNextStepView {
    func setupView() {
        self.backgroundColor = .oneBlueAnthracita
        self.titleLabel.textColor = .oneWhite
        self.titleLabel.font = .typography(fontName: .oneH200Bold)
        self.self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilityOneComponents.oneFooterOperativeView
        self.titleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneFooterOperativeHeader
    }
    
    func setAccessibilityInfo() {
        guard let viewModel = self.viewModel else { return }
        self.titleLabel.accessibilityLabel = localized("voiceover_andNowOptions", [StringPlaceholder(.number, "\(viewModel.elements.count)")]).text
    }
    
    func setAccessibilityForFooterViewItem(footerView: OneFooterNextStepItemView, model: OneFooterNextStepItemViewModel, index: Int) {
        guard let viewModel = self.viewModel else { return }
        footerView.isAccessibilityElement = true
        footerView.accessibilityTraits = .button
        footerView.accessibilityLabel = localized(model.titleKey)
        footerView.accessibilityValue = localized("voiceover_numberTotalCharacters", [StringPlaceholder(.number, "\(index + 1)"), StringPlaceholder(.number, "\(viewModel.elements.count)")]).text
    }
}

extension OneFooterNextStepView: AccessibilityCapable {}
