//
//  OnePastTransferCardView.swift
//  UIOneComponents
//
//  Created by Juan Diego Vázquez Moreno on 22/9/21.
//

import UI
import CoreFoundationLib

public protocol OnePastTransferCardViewDelegate: AnyObject {
    func didSelectPastTransfer(_ viewModel: OnePastTransferViewModel)
}

public final class OnePastTransferCardView: XibView {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var avatarView: OneAvatarView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var accountNumberLabel: UILabel!
    @IBOutlet private weak var accountLogoImageView: UIImageView!
    @IBOutlet private weak var dashedLineView: DashedLineView!
    @IBOutlet private weak var conceptLabel: UILabel!
    @IBOutlet private weak var transferTypeImageView: UIImageView!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var checkImageView: UIImageView!
    @IBOutlet private weak var scheduledContainerView: UIView!
    @IBOutlet private weak var scheduledLabel: UILabel!
    
    private var viewModel: OnePastTransferViewModel?
    
    public weak var delegate: OnePastTransferCardViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
}

// MARK: - Public functions
public extension OnePastTransferCardView {
    
    func setupPastTransferCard(_ viewModel: OnePastTransferViewModel) {
        self.viewModel = viewModel
        self.configureAvatar(viewModel.avatar)
        self.configureByStatus(viewModel.cardStatus)
        self.configureBankLogo(viewModel.bankLogoURL)
        self.setLabelTexts(viewModel)
        self.setTransferTypeImage(viewModel.transferType)
        self.setTransferSchedule(viewModel.transferScheduleType)
        self.setViewAccessibility()
    }

    func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
}

// MARK: - Configurations
private extension OnePastTransferCardView {
    
    func toggleStatus() {
        guard let viewModel = viewModel else { return }
        switch viewModel.cardStatus {
        case .selected:
            viewModel.cardStatus = .inactive
        case .inactive:
            viewModel.cardStatus = .selected
        case .disabled: break
        }
        self.configureByStatus(viewModel.cardStatus)
    }
    
    // MARK: - Layout configuration
    func configureView() {
        self.configureViews()
        self.configureLabels()
        self.configureImages()
        self.configureDefaultStatus()
        self.setAccessibilityIdentifiers()
    }
    
    func configureViews() {
        // Colors
        self.view?.backgroundColor = .white
        self.contentView.backgroundColor = .white
        self.dashedLineView.strokeColor = .oneMediumSkyGray
        self.scheduledContainerView.backgroundColor = .oneDarkTurquoise
        // Corners
        self.contentView.setOneCornerRadius(type: .oneShRadius8)
        self.scheduledContainerView.setOneCornerRadius(type: .oneShRadius4)
        // Gesture Recognizers
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnCard))
        self.view?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func configureLabels() {
        self.nameLabel.font = .typography(fontName: .oneB300Bold)
        self.accountNumberLabel.font = .typography(fontName: .oneB300Regular)
        self.conceptLabel.font = .typography(fontName: .oneB300Regular)
        self.dateLabel.font = .typography(fontName: .oneB200Bold)
        self.scheduledLabel.font = .typography(fontName: .oneB100Bold)
        self.scheduledLabel.textColor = .white
    }
    
    func configureImages() {
        self.checkImageView.image = Assets.image(named: "icnCheckOvalGreen")
    }
    
    func configureDefaultStatus() {
        self.accountLogoImageView.isHidden = true
        self.scheduledContainerView.isHidden = true
        self.configureByStatus(.inactive)
    }
    
    // MARK: - Status configuration
    func configureAvatar(_ viewModel: OneAvatarViewModel) {
        self.avatarView.setupAvatar(viewModel)
    }
    
    func configureByStatus(_ status: OnePastTransferViewModel.CardStatus) {
        self.accountLogoImageView.isHidden = true
        self.contentView.backgroundColor = status.backgroundColor
        switch status {
        case .inactive, .disabled:
            self.contentView.setOneShadows(type: .oneShadowLarge)
            self.checkImageView.isHidden = true
        case .selected:
            self.contentView.setOneShadows(type: .none)
            self.checkImageView.isHidden = false
        }
    }
    
    func configureBankLogo(_ logoUrl: String?) {
        guard let logoUrl = logoUrl else { return }
        _ = self.accountLogoImageView.setImage(url: logoUrl, completion: { [weak self] image in
            self?.accountLogoImageView.image = image
            self?.accountLogoImageView.isHidden = (self?.accountLogoImageView.image == nil)
        })
    }
    
    func setLabelTexts(_ viewModel: OnePastTransferViewModel) {
        self.nameLabel.text = viewModel.name
        self.accountNumberLabel.text = viewModel.shortIBAN
        self.conceptLabel.text = viewModel.concept
        self.amountLabel.attributedText = viewModel.formattedAmount
        self.dateLabel.text = viewModel.executedDateString
    }
    
    func setTransferTypeImage(_ transferType: OnePastTransferViewModel.TransferType) {
        if let iconName = transferType.transferTypeIcon {
            self.transferTypeImageView.image = Assets.image(named: iconName)
        }
    }
    
    func setTransferSchedule(_ schedule: OnePastTransferViewModel.TransferScheduleType) {
        self.scheduledLabel.text = schedule.localizedScheduleText?.uppercased()
        self.scheduledContainerView.isHidden = (schedule.localizedScheduleText == nil)
    }

    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.view?.accessibilityIdentifier = AccessibilityOneComponents.onePastTransferCardView + (suffix ?? "")
        self.nameLabel.accessibilityIdentifier = AccessibilityOneComponents.onePastTransferCardName + (suffix ?? "")
        self.accountNumberLabel.accessibilityIdentifier = AccessibilityOneComponents.onePastTransferCardAccount + (suffix ?? "")
        self.accountLogoImageView.accessibilityIdentifier = AccessibilityOneComponents.onePastTransferCardBankLogo + (suffix ?? "")
        self.conceptLabel.accessibilityIdentifier = AccessibilityOneComponents.onePastTransferCardConcept + (suffix ?? "")
        self.transferTypeImageView.accessibilityIdentifier = AccessibilityOneComponents.onePastTransferCardTransferTypeIcn + (suffix ?? "")
        self.amountLabel.accessibilityIdentifier = AccessibilityOneComponents.onePastTransferCardAmount + (suffix ?? "")
        self.checkImageView.accessibilityIdentifier = AccessibilityOneComponents.onePastTransferCardCheckIcn + (suffix ?? "")
        self.dateLabel.accessibilityIdentifier = AccessibilityOneComponents.onePastTransferCardDate + (suffix ?? "")
        self.scheduledLabel.accessibilityIdentifier = AccessibilityOneComponents.onePastTransferCardScheduled + (suffix ?? "")
        self.view?.isUserInteractionEnabled = true
    }
    
    func setAccesibilityInfo() {
        self.accessibilityElements = [self.contentView,
                                      self.nameLabel,
                                      self.accountNumberLabel,
                                      self.accountLogoImageView,
                                      self.conceptLabel,
                                      self.amountLabel,
                                      self.dateLabel].compactMap{$0}
        let accountLastFourDigits = self.viewModel?.shortIBAN?.substring(ofLast: 4) ?? ""
        let accountFourDigits = accountLastFourDigits.map { String($0) + " " }.joined()
        self.accountNumberLabel.accessibilityLabel = localized("voiceover_accountEnds", [StringPlaceholder(.value, accountFourDigits)]).text
        self.dateLabel.accessibilityLabel = self.viewModel?.dateDescription
        self.contentView.isAccessibilityElement = true
        self.contentView.accessibilityTraits = .button
        self.contentView.accessibilityLabel = localized("voiceover_recentTransfer", [StringPlaceholder(.name, self.viewModel?.name ?? "")]).text
        self.contentView.accessibilityValue = self.viewModel?.cardStatus == .selected ? localized("voiceover_selected") : localized("voiceover_unselected")
    }
    
    func setViewAccessibility() {
        self.setAccessibility(setViewAccessibility: self.setAccesibilityInfo)
    }
}

// MARK: - Private functions
private extension OnePastTransferCardView {
    @objc func didTapOnCard() {
        guard let viewModel = self.viewModel else { return }
        toggleStatus()
        self.delegate?.didSelectPastTransfer(viewModel)
        UIAccessibility.post(notification: .layoutChanged, argument: self.contentView)
    }
}

extension OnePastTransferCardView: AccessibilityCapable {}
