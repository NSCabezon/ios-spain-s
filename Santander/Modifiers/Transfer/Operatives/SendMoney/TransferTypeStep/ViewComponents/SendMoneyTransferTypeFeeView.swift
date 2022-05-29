//
//  SendMoneyTransferTypeFeeView.swift
//  Santander
//
//  Created by Angel Abad Perez on 25/11/21.
//

import UI
import UIOneComponents
import CoreFoundationLib

protocol SendMoneyTransferTypeFeeViewDelegate: AnyObject {
    func didSelectFeeView(at index: Int)
}

final class SendMoneyTransferTypeFeeView: UIView {
    private enum Constants {
        static let defaultIndex: Int = -1
        static let descriptionKey: String = "sendType_label_commission"
        enum StackView {
            static let spacing: CGFloat = 4.0
            static let margins = UIEdgeInsets(top: 16.0,
                                              left: .zero,
                                              bottom: .zero,
                                              right: .zero)
            static let minWidth: CGFloat = 82.0
        }
    }
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .trailing
        stackView.spacing = Constants.StackView.spacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = Constants.StackView.margins
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.configureText(withKey: Constants.descriptionKey)
        descriptionLabel.font = .typography(fontName: .oneB200Regular)
        descriptionLabel.textColor = .oneLisboaGray
        descriptionLabel.sizeToFit()
        return descriptionLabel
    }()
    private lazy var amountLabel: UILabel = {
        let amountLabel = UILabel()
        amountLabel.textColor = .oneLisboaGray
        return amountLabel
    }()
    var index: Int = Constants.defaultIndex
    var status: OneStatus = .inactive {
        didSet {
            self.changeByStatus()
        }
    }
    weak var delegate: SendMoneyTransferTypeFeeViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: SendMoneyTransferTypeFeeViewModel, index: Int) {
        self.setAmountLabelText(viewModel)
        self.index = index
        self.status = viewModel.status
        self.setAccessibilityIdentifiers(viewModel.accessibilitySuffix)
    }
    
    func changeStatus(to status: OneStatus) {
        self.status = status
    }
}

private extension SendMoneyTransferTypeFeeView {
    func setupView() {
        self.configureView()
        self.configureStackView()
        self.setAccessibilityIdentifiers()
    }
    
    func configureView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func configureStackView() {
        self.addSubview(self.stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.StackView.minWidth)
        ])
        self.stackView.addArrangedSubview(self.descriptionLabel)
        self.stackView.addArrangedSubview(self.amountLabel)
    }
    
    func setAmountLabelText(_ viewModel: SendMoneyTransferTypeFeeViewModel) {
        self.amountLabel.attributedText = viewModel.formattedAmount
        self.amountLabel.sizeToFit()
    }
    
    func changeByStatus() {
        switch self.status {
        case .activated:
            self.setActivatedStatus()
        default:
            self.setInactiveStatus()
        }
    }
    
    func setInactiveStatus() {
        self.descriptionLabel.textColor = .oneLisboaGray
        self.amountLabel.textColor = .oneLisboaGray
    }
    
    func setActivatedStatus() {
        self.descriptionLabel.textColor = .oneDarkTurquoise
        self.amountLabel.textColor = .oneDarkTurquoise
    }
    
    @objc func didTapOnView() {
        guard self.status != .activated else { return }
        self.changeStatus(to: .activated)
        self.delegate?.didSelectFeeView(at: self.index)
    }

    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.descriptionLabel.accessibilityIdentifier = AccessibilityOneComponents.oneRadioButtonFee + (suffix ?? "")
        self.amountLabel.accessibilityIdentifier = AccessibilityOneComponents.oneRadioButtonAmount + (suffix ?? "")
    }
}
