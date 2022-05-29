//
//  NewRecipientHelperView.swift
//  TransferOperatives
//
//  Created by Angel Abad Perez on 8/3/22.
//

import UI
import UIOneComponents
import CoreFoundationLib

struct NewRecipientAliasHelperViewModel {
    var imageKey: String? = nil
    let titleKey: String
    let subtitleKey: String
}

enum NewRecipientAliasHelperViewType {
    private enum ViewModels {
        static let aliasInfoViewModel = NewRecipientAliasHelperViewModel(imageKey: nil, titleKey: "sendMoney_label_alias", subtitleKey: "sendMoney_text_alias")
        static let existingAccountViewModel = NewRecipientAliasHelperViewModel(imageKey: "icnAlertView", titleKey: "sendMoney_title_theContactExists", subtitleKey: "sendMoney_text_theContactExists")
        static let duplicatedAliasViewModel = NewRecipientAliasHelperViewModel(imageKey: "icnAlertView", titleKey: "sendMoney_title_aliasAlreadyInUse", subtitleKey: "sendMoney_text_aliasAlreadyInUse")
    }
    
    case aliasInfo
    case existingAccount
    case duplicatedAlias
    
    static func getViewModel(for helperType: NewRecipientAliasHelperViewType) -> NewRecipientAliasHelperViewModel {
        switch helperType {
        case .aliasInfo: return ViewModels.aliasInfoViewModel
        case .existingAccount: return ViewModels.existingAccountViewModel
        case .duplicatedAlias: return ViewModels.duplicatedAliasViewModel
        }
    }
}

protocol NewRecipientAliasHelperViewDelegate: AnyObject {
    func aliasHelperDidTapButton()
}

final class NewRecipientAliasHelperView: XibView {
    @IBOutlet private weak var mainIcon: UIImageView!
    @IBOutlet private weak var mainIconHeight: NSLayoutConstraint!
    @IBOutlet private weak var mainIconBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var floatingButton: OneFloatingButton!
    
    weak var delegate: NewRecipientAliasHelperViewDelegate?
    private var viewModel: NewRecipientAliasHelperViewModel? {
        didSet {
            self.setIconImage()
            self.setLabelsText()
            self.setAccessibilityIdentifiers()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    func setViewModel(_ viewModel: NewRecipientAliasHelperViewModel) {
        self.viewModel = viewModel
    }
    
    @IBAction func didTapFloatingButton(_ sender: Any) {
        self.delegate?.aliasHelperDidTapButton()
    }
}

private extension NewRecipientAliasHelperView {
    enum Constants {
        static let floatingButtonKey: String = "generic_link_ok"
        enum Constraints {
            static let iconHeight: CGFloat = 65.0
            static let iconBottom: CGFloat = 19.0
        }
    }
    
    func setupViews() {
        self.setupLabels()
        self.setupFloatingButton()
    }
    
    func setupLabels() {
        self.titleLabel.font = .typography(fontName: .oneH300Bold)
        self.titleLabel.textColor = .oneLisboaGray
        self.subtitleLabel.font = .typography(fontName: .oneB400Regular)
        self.subtitleLabel.textColor = .oneLisboaGray
    }
    
    func setupFloatingButton() {
        self.floatingButton.configureWith(type: .primary,
                                          size: .small(OneFloatingButton.ButtonSize.SmallButtonConfig(title: Constants.floatingButtonKey)),
                                          status: .ready)
    }
    
    func setIconImage() {
        guard let viewModel = self.viewModel else { return }
        self.mainIcon.image = Assets.image(named: viewModel.imageKey ?? "")
        self.mainIcon.isHidden = self.mainIcon.image == nil ? true : false
        self.mainIconHeight.constant = self.mainIcon.image == nil ? .zero : Constants.Constraints.iconHeight
        self.mainIconBottomConstraint.constant = self.mainIcon.image == nil ? .zero : Constants.Constraints.iconBottom
    }
    
    func setLabelsText() {
        guard let viewModel = self.viewModel else { return }
        self.titleLabel.configureText(withKey: viewModel.titleKey)
        self.subtitleLabel.configureText(withKey: viewModel.subtitleKey)
    }
    
    func setAccessibilityIdentifiers() {
        guard let viewModel = self.viewModel else { return }
        self.mainIcon.accessibilityIdentifier = AccessibilitySendMoneyDestination.NewRecipientView.Alias.mainIcon
        self.titleLabel.accessibilityIdentifier = viewModel.titleKey
        self.subtitleLabel.accessibilityIdentifier = viewModel.subtitleKey
    }
}

