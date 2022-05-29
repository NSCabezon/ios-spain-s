//
//  BizumHistoricTableViewCell.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 27/10/2020.
//

import UI
import CoreFoundationLib
import ESUI

protocol BizumHistoricTableViewCellDelegate: class {
    func didSelectActionWithViewModel(_ viewModel: BizumAvailableActionViewModel)
}

final class BizumHistoricSimpleTableViewCell: UITableViewCell {
    
    static let identifier = "BizumHistoricSimpleTableViewCell"
    
    @IBOutlet weak private var typeIconView: UIImageView!
    @IBOutlet weak private var initialsView: UIView!
    @IBOutlet weak private var initialsLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!
    @IBOutlet weak private var contentStackView: UIStackView!
    @IBOutlet weak private var stateImage: UIImageView!
    @IBOutlet weak private var stateLabel: UILabel!
    @IBOutlet weak private var bottomButtonContainer: UIStackView!
    @IBOutlet weak private var separatorView: PointLine!
    
    weak var delegate: BizumHistoricTableViewCellDelegate?

    private let conceptStackView = UIStackView()
    private let conceptLabel = UILabel()
    private let attachmentImageView = UIImageView()
    private let phoneNumberLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bottomButtonContainer.removeAllArrangedSubviews()
        self.separatorView.isHidden = false
    }

    func set(_ viewModel: BizumHistoricSimpleCellViewModel) {
        setHeader(viewModel)
        setContentStackView(viewModel)
        if let validActions = viewModel.actionsEvaluator?.validActions() {
            validActions.forEach { (actionViewModel) in
                let button = BizumActionButton()
                button.accessibilityIdentifier = actionViewModel.accessibilityIdentifier
                button.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setViewModel(actionViewModel)
                self.bottomButtonContainer.addArrangedSubview(button)
                button.delegate = self
            }
        }
    }
    
    func hideSeparatorView(_ isHidden: Bool) {
        self.separatorView.isHidden = isHidden
    }
}

extension BizumHistoricSimpleTableViewCell: BizumActionButtonDelegate {
    func didTapOnButtonWithViewModel(_ viewModel: BizumAvailableActionViewModel) {
        self.delegate?.didSelectActionWithViewModel(viewModel)
    }
}

// MARK: - Config View
private extension BizumHistoricSimpleTableViewCell {
    
    func configView() {
        selectionStyle = .none
        initialsView.layer.cornerRadius = initialsView.frame.width / 2
        configAccesibilityLabels()
        configFonts()
        configConceptStackView()
        configAttachmentImageView()
        configContentStackView()
    }
    
    func configFonts() {
        initialsLabel.setSantanderTextFont(type: .bold, size: 15, color: .white)
        titleLabel.setSantanderTextFont(type: .regular, size: 10.0, color: .lisboaGray)
        subtitleLabel.setSantanderTextFont(type: .bold, size: 16.0, color: .lisboaGray)
        amountLabel.setSantanderTextFont(type: .bold, size: 20.0, color: .lisboaGray)
        conceptLabel.setSantanderTextFont(type: .bold, size: 14.0, color: .lisboaGray)
        phoneNumberLabel.setSantanderTextFont(type: .regular, size: 12.0, color: .lisboaGray)
        stateLabel.setSantanderTextFont(type: .bold, size: 12, color: .black)
    }
    
    func configAccesibilityLabels() {
        self.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricCell 
        typeIconView.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricIconType
        initialsLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricLabelInitials
        titleLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricLabelTitle
        subtitleLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricLabelSubtitle
        amountLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricLabelAmount
        phoneNumberLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricLabelPhoneNumber
        conceptLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricLabelConcept
        attachmentImageView.accessibilityIdentifier = AccessibilityBizumHistoric.icnClip
        stateImage.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricIconState
        stateLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricLabelState        
    }
    
    func configAttachmentImageView() {
        attachmentImageView.image = ESAssets.image(named: "icnClip")
        attachmentImageView.translatesAutoresizingMaskIntoConstraints = false
        attachmentImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        attachmentImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }

    func configConceptStackView() {
        conceptStackView.axis = .horizontal
        conceptStackView.alignment = .center
        conceptStackView.distribution = .fill
        conceptStackView.addArrangedSubview(conceptLabel)
        conceptStackView.addArrangedSubview(attachmentImageView)
    }
    
    func configContentStackView() {
        contentStackView.addArrangedSubview(phoneNumberLabel)
        contentStackView.addArrangedSubview(conceptStackView)
    }
    
}

// MARK: - Set View
private extension BizumHistoricSimpleTableViewCell {
    
    func setHeader(_ viewModel: BizumHistoricSimpleCellViewModel) {
        typeIconView.image = viewModel.getTypeImage()
        initialsView.backgroundColor = viewModel.iconColor.color
        initialsLabel.text = viewModel.initials
        titleLabel.text = viewModel.title
        setSubtitle(viewModel)
        let attributedAmount = MoneyDecorator(viewModel.amount,
                       font: UIFont.santander(family: .text,
                                              type: .bold,
                                              size: 20.0), decimalFontSize: 16.0)
            .formatAsMillions()
        amountLabel.attributedText = attributedAmount
    }
    
    func setSubtitle(_ viewModel: BizumHistoricSimpleCellViewModel) {
        if let attributedSubtitle = viewModel.getHighlightedSubtitle() {
            subtitleLabel.attributedText = attributedSubtitle
        } else {
            subtitleLabel.text = viewModel.subtitle ?? viewModel.formattedPhoneNumber()
        }
    }

    func setPhoneNumber(_ viewModel: BizumHistoricSimpleCellViewModel) {
        if let attributedSubtitle = viewModel.getHighlightedPhone() {
            phoneNumberLabel.attributedText = attributedSubtitle
        } else {
            phoneNumberLabel.text = viewModel.formattedPhoneNumber()
        }
    }

    func setContentStackView(_ viewModel: BizumHistoricSimpleCellViewModel) {
        setConceptLabel(viewModel)
        conceptStackView.isHidden = (viewModel.concept == nil && viewModel.getHighlightedConcept() == nil)
        attachmentImageView.isHidden = viewModel.hasAttachment == false
        setPhoneNumber(viewModel)
        phoneNumberLabel.isHidden = viewModel.subtitle == nil
        setStateView(viewModel)
    }

    func setConceptLabel(_ viewModel: BizumHistoricSimpleCellViewModel) {
        if let attributeConcept = viewModel.getHighlightedConcept() {
            conceptLabel.attributedText = attributeConcept
        } else {
            conceptLabel.text = viewModel.concept
        }
    }
    
    func setStateView(_ viewModel: BizumHistoricSimpleCellViewModel) {
        stateImage.image = viewModel.state?.image
        stateLabel.text = viewModel.stateLabel
        stateLabel.textColor = viewModel.state?.color
    }
    
}
