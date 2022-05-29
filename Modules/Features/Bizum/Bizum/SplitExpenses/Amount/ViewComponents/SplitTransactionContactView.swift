//
//  SplitTransactionContactView.swift
//  Bizum

import UI
import CoreFoundationLib

protocol SplitTransactionContactViewProtocol: class {
    func update(with viewModel: SplitTransactionContactViewModel)
}

final class SplitTransactionContactView: XibView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var nameAvatarLabel: UILabel!
    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountDescriptionLabel: UILabel!
    @IBOutlet weak var dottedSeparatorView: PointLine!
    @IBOutlet weak var plainSeparatorView: UIView!
    @IBOutlet weak var avatarContainerLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var thumbNailImageView: UIImageView!

    private var viewModel: SplitTransactionContactViewModel?
    var action: ((SplitTransactionContactViewModel) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: SplitTransactionContactViewModel) {
        let cornerRadius = self.avatarContainerView.layer.frame.width / 2
        self.avatarContainerView.drawBorder(cornerRadius: cornerRadius, color: .white, width: 1.0)
        if let imageData = viewModel.thumbnailData {
            self.thumbNailImageView.image = UIImage(data: imageData)
            self.thumbNailImageView.isHidden = false
            self.nameAvatarLabel.isHidden = true
            self.thumbNailImageView.layer.cornerRadius = cornerRadius
        } else {
            self.nameAvatarLabel.isHidden = false
            self.thumbNailImageView.isHidden = true
            self.nameAvatarLabel.text = viewModel.initials
        }
        self.nameAvatarLabel.text = viewModel.initials
        self.nameLabel.text = viewModel.name
        self.phoneLabel.text = viewModel.phone.tlfFormatted()
        self.nameLabel.isHidden = viewModel.name == nil
        self.phoneLabel.isHidden = viewModel.isPhoneHidden
        self.avatarContainerView.backgroundColor = viewModel.colorModel?.color
        self.amountLabel.attributedText = viewModel.splittedAmountFormatted
        self.viewModel = viewModel
        self.dottedSeparatorView.isHidden = viewModel.showPlainSeparatorView
        self.plainSeparatorView.backgroundColor = .mediumSkyGray
        self.plainSeparatorView.isHidden = !viewModel.showPlainSeparatorView
        self.deleteButton.isHidden = viewModel.isDeviceUser
        if let tag = viewModel.tag {
            self.tag = tag
        }
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        guard let viewModel = self.viewModel else { return }
        action?(viewModel)
    }
    
    func getViewModel() -> SplitTransactionContactViewModel? {
        return self.viewModel
    }
    
    func setAvatarConstraintToZero() {
        guard let viewModel = self.viewModel,
              viewModel.isDeviceUser else { return }
        self.avatarContainerLabelLeadingConstraint.constant = 0
    }
    
    func setAvatarConstraintLeadingSpace() {
        guard let viewModel = self.viewModel,
              viewModel.isDeviceUser else { return }
        self.avatarContainerLabelLeadingConstraint.constant = 38
    }
}

private extension SplitTransactionContactView {
    func setupView() {
        self.nameLabel.setSantanderTextFont(type: .bold, size: 14.0, color: .lisboaGray)
        self.phoneLabel.setSantanderTextFont(type: .regular, size: 14.0, color: .lisboaGray)
        self.nameAvatarLabel.setSantanderTextFont(type: .bold, size: 15.0, color: .white)
        self.amountDescriptionLabel.setSantanderTextFont(type: .regular, size: 12.0, color: .grafite)
        self.amountLabel.setSantanderTextFont(type: .regular, size: 17.0, color: .lisboaGray)
        self.deleteButton.setImage(Assets.image(named: "icnRemoveGreen"), for: .normal)
    }
    
    func setupAccessibilityIdentifiers() {
        self.nameLabel.accessibilityIdentifier = AccessibilityBizumSplitExpenses.amountContactNameLabel
        self.phoneLabel.accessibilityIdentifier = AccessibilityBizumSplitExpenses.amountContactPhoneLabel
        self.amountDescriptionLabel.accessibilityIdentifier = AccessibilityBizumSplitExpenses.amountContactAmountTitleLabel
        self.amountLabel.accessibilityIdentifier = AccessibilityBizumSplitExpenses.amountContactAmounLabel
        self.deleteButton.accessibilityIdentifier = AccessibilityBizumSplitExpenses.amountContactBtnTrash
        self.nameAvatarLabel.accessibilityIdentifier = AccessibilityBizumSplitExpenses.amountContactAvatarNameLabel
    }
}

extension SplitTransactionContactView: SplitTransactionContactViewProtocol {
    func update(with viewModel: SplitTransactionContactViewModel) {
        self.setViewModel(viewModel)
    }
}
