//
//  OneSegmentedItemView.swift
//  UIOneComponents
//
//  Created by Carlos Monfort Gómez on 24/9/21.
//

import UI
import CoreFoundationLib

protocol OneSegmentedItemDelegate: AnyObject {
    func didSelectOneSegmentedItem(_ index: Int)
}

public final class OneSegmentedItemView: XibView {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    weak var delegate: OneSegmentedItemDelegate?
    private var viewModel: OneSegmentedItemViewModel?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setViewModel(_ viewModel: OneSegmentedItemViewModel) {
        self.viewModel = viewModel
        self.titleLabel.configureText(withKey: "", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
        self.titleLabel.text = localized(viewModel.descriptionKey)
        self.iconImageView.image = Assets.image(named: viewModel.imageKey)
        self.setAccesibilityIdentifiers(viewModel)
    }
    
    public func setSegmentedStyle(_ isSelected: Bool) {
        self.titleLabel.textColor = isSelected ? .oneDarkTurquoise : .oneLisboaGray
        self.titleLabel.font = .typography(fontName: isSelected ? .oneB300Bold : .oneB300Regular)
        self.iconImageView.image = self.iconImageView.image?.withRenderingMode(.alwaysTemplate)
        self.iconImageView.tintColor = isSelected ? .oneDarkTurquoise : .oneLisboaGray
    }
    
    @IBAction private func didTapOnOneSegmentedItem(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didSelectOneSegmentedItem(viewModel.index)
    }
}

private extension OneSegmentedItemView {
    func setupView() {
        self.view?.backgroundColor = .clear
        self.containerView.backgroundColor = .clear
    }
    
    func setAccesibilityIdentifiers(_ viewModel: OneSegmentedItemViewModel) {
        self.iconImageView.accessibilityIdentifier = viewModel.imageKey
        self.titleLabel.accessibilityIdentifier = viewModel.descriptionKey
    }
}
