//
//  SubmenuFooter.swift
//
//  Created by Boris Chirino Fernandez on 16/3/22.
//
import UI
import UIKit

final class SubmenuFooterView: UIView {
    private enum Constants {
        static let separatorAlpha = 0.3
        static let separatorHeight = 1.0
        static let titleFontSize = 13.0
        enum Constraints {
            static let separatorTop = 5.0
            static let titleTop = 30.0
            static let titleLeading = 34.0
            static let titleHeight = 10.0
            static let stackViewTop = 20.0
        }
    }
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 1
        return stackView
    }()
    
    private lazy var separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.mediumSanGray.withAlphaComponent(Constants.separatorAlpha)
        separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorHeight).isActive = true
        self.stackView.addArrangedSubview(separatorView)
        return separatorView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .santander(family: .text, type: .bold, size: Constants.titleFontSize)
        label.textColor = .grafite
        label.accessibilityIdentifier = "menu_label_interest"
        label.configureText(withKey: "menu_label_interest", andConfiguration: nil)
        return label
    }()

    func setView(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SubmenuFooterView {
    func setupUI() {
        self.backgroundColor = .white
        self.addSubview(stackView)
        self.addSubview(separatorView)
        self.addSubview(titleLabel)
        activateConstraints()
    }
    
    func activateConstraints() {
        NSLayoutConstraint.activate([
            separatorView.bottomAnchor.constraint(equalTo: topAnchor,
                                                  constant: Constants.Constraints.separatorTop),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor,
                                               constant: Constants.Constraints.titleTop),
            titleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor,
                                                constant: Constants.Constraints.titleLeading),
            titleLabel.heightAnchor.constraint(equalToConstant: Constants.Constraints.titleHeight)
        ])
        // Hack to fix AutoLayout bug related to UIView-Encapsulated-Layout-Width
        let leadingContraint = self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        leadingContraint.priority = .defaultHigh
        // Hack to fix AutoLayout bug related to UIView-Encapsulated-Layout-Height
        let topSpace = Constants.Constraints.stackViewTop + Constants.Constraints.titleTop + Constants.Constraints.titleHeight
        let topConstraint = self.stackView.topAnchor.constraint(equalTo: self.topAnchor,
                                                                constant:topSpace)
        topConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
                    leadingContraint,
                    topConstraint,
                    self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                    self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
