//
//  FractionalPaymentBox.swift
//  Account
//
//  Created by César González on 21/12/21.
//

import CoreFoundationLib
import UIKit
import UI

protocol FractionalPaymentBoxViewDelegate: AnyObject {
    func didSelectPaymentBox(viewModel: FinanceableInfoViewModel.FractionalPaymentBoxViewModel)
}

final class FractionalPaymentBox: UIView {
    private let contentView = UIView()
    
    private let icon = UIImageView()
    private let title = UILabel()
    private let subtitle = UILabel()
    weak var delegate: FractionalPaymentBoxViewDelegate?
    
    private var viewModel: FinanceableInfoViewModel.FractionalPaymentBoxViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            icon.image = Assets.image(named: viewModel.iconName)?.withRenderingMode(.alwaysOriginal)
            title.configureText(withLocalizedString: viewModel.title,
                                andConfiguration: titleConfiguration)
            subtitle.configureText(withLocalizedString: viewModel.subTitle,
                                   andConfiguration: subTitleConfiguration)
        }
    }
    
    private var titleConfiguration: LocalizedStylableTextConfiguration {
        LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .regular, size: 12),
            alignment: .left,
            lineBreakMode: .byTruncatingTail)
    }
    
    private var subTitleConfiguration: LocalizedStylableTextConfiguration {
        LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .regular, size: 14),
            alignment: .left,
            lineBreakMode: .byTruncatingTail)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func set(_ viewModel: FinanceableInfoViewModel.FractionalPaymentBoxViewModel) {
        self.viewModel = viewModel
    }
}

private extension FractionalPaymentBox {
    func commonInit() {
        setupContentView()
        setupShadow()
        setupIcon()
        setupTitle()
        setupSubTitle()
        setupInteraction()
    }
    
    func setupContentView() {
        addSubview(contentView)
        contentView.fullFit()
        contentView.backgroundColor = .white
    }
    
    func setupShadow() {
        let shadowConfiguration = ShadowConfiguration(
            color: .mediumSkyGray,
            opacity: 0.7,
            radius: 2,
            withOffset: 1,
            heightOffset: 2
        )
        contentView.drawRoundedBorderAndShadow(
            with: shadowConfiguration,
            cornerRadius: 8,
            borderColor: .lightSkyBlue,
            borderWith: 1
        )
    }
    
    func setupIcon() {
        addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 32).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    func setupTitle() {
        addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 12).isActive = true
        title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        contentView.trailingAnchor.constraint(equalTo: title.trailingAnchor, constant: 12).isActive = true
        title.textColor = UIColor.brownishGray
    }
    
    func setupSubTitle() {
        addSubview(subtitle)
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
        bottomAnchor.constraint(greaterThanOrEqualTo: subtitle.bottomAnchor, constant: 12.0).isActive = true
        subtitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        subtitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        subtitle.textColor = UIColor.lisboaGray
        subtitle.numberOfLines = 3
    }
    
    func setupInteraction() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func viewTapped() {
        guard let viewModel = viewModel else {
            return
        }
        didSelectPaymentBox(viewModel: viewModel)
    }
}

extension FractionalPaymentBox: FractionalPaymentBoxViewDelegate {
    func didSelectPaymentBox(viewModel: FinanceableInfoViewModel.FractionalPaymentBoxViewModel) {
        self.delegate?.didSelectPaymentBox(viewModel: viewModel)
    }
}
