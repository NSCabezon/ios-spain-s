//
//  BooleanFeatureFlagTableViewCell.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 15/3/22.
//

import UIKit
import UI
import UIOneComponents
import OpenCombine
import CoreDomain
import CoreFoundationLib

final class BooleanFeatureFlagTableViewCell: UITableViewCell {
    
    private let subject = PassthroughSubject<Bool, Never>()
    var publisher: AnyPublisher<Bool, Never> {
        return subject.eraseToAnyPublisher()
    }
    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .oneLisboaGray
        label.font = .typography(fontName: .oneB400Bold)
        label.numberOfLines = 1
        return label
    }()
    private lazy var toggle: OneToggleView = {
        let toggle = OneToggleView()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        toggle.widthAnchor.constraint(equalToConstant: 37).isActive = true
        toggle.publisher.subscribe(subject).store(in: &subscriptions)
        return toggle
    }()
    private lazy var line: DottedLineView = {
        let line = DottedLineView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 2).isActive = true
        return line
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setup(with feature: FeatureFlagRepresentable, value: Bool) {
        toggle.isOn = value
        toggle.setAccessibilitySuffix("_\(feature.identifier)")
        label.text = localized(feature.description)
        label.accessibilityIdentifier = "featureFlags_text_\(feature.identifier)"
    }
}

private extension BooleanFeatureFlagTableViewCell {
    func setupView() {
        let stack = verticalStackView {
            horizontalStackView {
                label
                toggle
            }
            line
        }
        contentView.addSubview(stack, topMargin: .oneSizeSpacing12, bottomMargin: .none, leftMargin: .oneSizeSpacing16, rightMargin: .oneSizeSpacing16)
    }
    
    func verticalStackView(@ViewBuilder builder: () -> [UIView]) -> UIStackView {
        let views = builder()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        views.forEach { stackView.addArrangedSubview($0) }
        return stackView
    }
    
    func horizontalStackView(@ViewBuilder builder: () -> [UIView]) -> UIStackView {
        let views = builder()
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        views.forEach { stackView.addArrangedSubview($0) }
        return stackView
    }
    
    @resultBuilder struct ViewBuilder {
        static func buildBlock(_ components: UIView...) -> [UIView] {
            return components
        }
    }
}
