//
//  BizumHistoricTableViewCell.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 27/10/2020.
//

import UI
import CoreFoundationLib
import ESUI

final class BizumHistoricMultipleTableViewCell: UITableViewCell {
    
    static let identifier = "BizumHistoricMultipleTableViewCell"
    
    @IBOutlet weak private var typeIconView: UIImageView!
    @IBOutlet weak private var iconView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!
    @IBOutlet weak private var contentStackView: UIStackView!
    @IBOutlet weak private var separatorView: PointLine!

    private let conceptStackView = UIStackView()
    private let conceptLabel = UILabel()
    private let attachmentImageView = UIImageView()
    private let contactsStackView = UIStackView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configView()
    }
    
    override func prepareForReuse() {
        self.separatorView.isHidden = false
    }

    func set(_ viewModel: BizumHistoricMultipleCellViewModel) {
        setHeader(viewModel)
        setContentStackView(viewModel)
    }

    func hideSeparatorView(_ isHidden: Bool) {
        self.separatorView.isHidden = isHidden
    }
}

// MARK: - Config View
private extension BizumHistoricMultipleTableViewCell {
    
    func configView() {
        selectionStyle = .none
        configFonts()
        configAccesibilityLabels()
        configContactsStackView()
        configConceptStackView()
        configAttachmentImageView()
        configContentStackView()
        self.separatorView.isHidden = false
    }
    
    func configFonts() {
        titleLabel.setSantanderTextFont(type: .regular, size: 10.0, color: .lisboaGray)
        subtitleLabel.setSantanderTextFont(type: .bold, size: 16.0, color: .lisboaGray)
        amountLabel.setSantanderTextFont(type: .bold, size: 20.0, color: .lisboaGray)
        conceptLabel.setSantanderTextFont(type: .bold, size: 14.0, color: .lisboaGray)
    }
    
    func configAccesibilityLabels() {
        typeIconView.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricIconType
        iconView.accessibilityIdentifier = AccessibilityBizumHistoric.icnMultiple
        titleLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricLabelTitle
        subtitleLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricLabelSubtitle
        amountLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricLabelAmount
        conceptLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricLabelConcept
        attachmentImageView.accessibilityIdentifier = AccessibilityBizumHistoric.icnClip
    }
    
    func configAttachmentImageView() {
        attachmentImageView.image = ESAssets.image(named: "icnClip")
        attachmentImageView.translatesAutoresizingMaskIntoConstraints = false
        attachmentImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        attachmentImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    func configContactsStackView() {
        contactsStackView.axis = .horizontal
        contactsStackView.alignment = .center
        contactsStackView.distribution = .equalSpacing
        contactsStackView.spacing = 5
    }

    func configConceptStackView() {
        conceptStackView.axis = .horizontal
        conceptStackView.alignment = .center
        conceptStackView.distribution = .fill
        conceptStackView.addArrangedSubview(conceptLabel)
        conceptStackView.addArrangedSubview(attachmentImageView)
    }
        
    func configContentStackView() {
        contentStackView.addArrangedSubview(contactsStackView)
        contentStackView.addArrangedSubview(conceptStackView)
    }
    
}

// MARK: - Set View
private extension BizumHistoricMultipleTableViewCell {
    
    func setHeader(_ viewModel: BizumHistoricMultipleCellViewModel) {
        typeIconView.image = viewModel.getTypeImage()
        iconView.image = ESAssets.image(named: "icnMultiple")
        titleLabel.text = viewModel.title
        subtitleLabel.textColor = .lisboaGray
        let spholder = StringPlaceholder(.number, String(viewModel.totalContacts))
        let textConfiguration = LocalizedStylableTextConfiguration(font: UIFont.santander(size: 16))
        subtitleLabel.configureText(withLocalizedString: localized("bizum_label_peopleNumber", [spholder]),
                            andConfiguration: textConfiguration)
        let attributedAmount = MoneyDecorator(viewModel.amount,
                       font: UIFont.santander(family: .text,
                                              type: .bold,
                                              size: 20.0), decimalFontSize: 16.0)
            .formatAsMillions()
        amountLabel.attributedText = attributedAmount
    }
        
    func setContentStackView(_ viewModel: BizumHistoricMultipleCellViewModel) {
        setContacts(viewModel)
        setConceptLabel(viewModel)
        conceptStackView.isHidden = (viewModel.concept == nil && viewModel.getHighlightedConcept() == nil)
        attachmentImageView.isHidden = viewModel.hasAttachment == false
    }

    func setConceptLabel(_ viewModel: BizumHistoricMultipleCellViewModel) {
        if let attributeConcept = viewModel.getHighlightedConcept() {
            conceptLabel.attributedText = attributeConcept
        } else {
            conceptLabel.text = viewModel.concept
        }
    }
    
    func setContacts(_ viewModel: BizumHistoricMultipleCellViewModel) {
        contactsStackView.subviews.forEach { $0.removeFromSuperview() }
        if viewModel.initials.count > 0 {
            let initials = viewModel.initials.prefix(3)
            initials.forEach { initial in
                let view = BizumHistoricInitialsView(frame: CGRect(x: 0, y: 0, width: 31, height: 31))
                view.translatesAutoresizingMaskIntoConstraints = false
                view.widthAnchor.constraint(equalToConstant: 31).isActive = true
                view.heightAnchor.constraint(equalToConstant: 31).isActive = true
                view.set(initial.initials, color: initial.colorViewModel.color)
                contactsStackView.addArrangedSubview(view)
            }
            if viewModel.getRestCount() > 0 {
                let label = UILabel()
                label.textColor = .lisboaGray
                let spholder = StringPlaceholder(.number, String(viewModel.getRestCount()))
                let textConfiguration = LocalizedStylableTextConfiguration(font: UIFont.santander(size: 16))
                label.configureText(withLocalizedString: localized("bizum_label_andMore", [spholder]),
                                    andConfiguration: textConfiguration)
                label.accessibilityIdentifier = AccessibilityBizumHistoric.bizumAndMore
                contactsStackView.addArrangedSubview(label)
            }
        }
    }
    
}
