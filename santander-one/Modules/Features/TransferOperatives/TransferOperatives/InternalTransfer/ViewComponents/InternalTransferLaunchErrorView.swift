//
//  SendMoneyCannotOperationView.swift
//  UIOneComponents
//
//  Created by Cristobal Ramos Laina on 18/2/22.
//

import UI
import CoreFoundationLib
import UIOneComponents

public final class InternalTransferLaunchErrorView: XibView {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var floattingButton: OneFloatingButton!
    var didTapOnAccept: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAppearance()
    }
    @IBAction func didTapOnButton(_ sender: Any) {
        didTapOnAccept?()
    }
    
    public func configureFloatingButton() {
        floattingButton.configureWith(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: localized("generic_button_accept"),
                                                            icons: .none, fullWidth: true)),
            status: .ready)
    }
    
    public func setSubtitle(_ error: InternalTransferOperativeError) {
        switch error {
        case .minimunAccounts: subtitleLabel.text = localized("sendMoney_text_twoAccountsRequired")
        default: break
        }
    }
}

private extension InternalTransferLaunchErrorView {
    func setAppearance() {
        titleLabel.text = localized("sendMoney_title_cannotOperation")
        subtitleLabel.text = localized("sendMoney_text_notCompatibleOperation")
        imageView.image = Assets.image(named: "oneIcnWarning")
        titleLabel.font = .typography(fontName: .oneH300Bold)
        subtitleLabel.font = .typography(fontName: .oneB400Regular)
        titleLabel.textColor = .lisboaGray
        subtitleLabel.textColor = .lisboaGray
        configureFloatingButton()
        setAccesibilityIdentifiers()
    }
    
    func setAccesibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = AccesibilityInternalTransferLaunchErrorView.titleLabel
        subtitleLabel.accessibilityIdentifier = AccesibilityInternalTransferLaunchErrorView.subtitleLabel
        imageView.accessibilityIdentifier = AccesibilityInternalTransferLaunchErrorView.imageView
        floattingButton.accessibilityIdentifier = AccesibilityInternalTransferLaunchErrorView.button
        view?.accessibilityIdentifier = AccesibilityInternalTransferLaunchErrorView.view
    }
}
