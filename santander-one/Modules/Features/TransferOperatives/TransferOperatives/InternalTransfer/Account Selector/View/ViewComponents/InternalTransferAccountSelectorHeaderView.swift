//
//  InternalTransferAccountSelectorHeaderView.swift
//  TransferOperatives
//
//  Created by Mario Rosales Maillo on 15/2/22.
//

import UI
import UIOneComponents
import CoreFoundationLib
import OpenCombine

public enum InternalTransferAccountSelectorHeaderType {
    case hidden
    case showHiddenAccounts
    case showFilteredAccouts
    case showHiddenAndFilteredAccounts
}

final class InternalTransferAccountSelectorHeaderView: XibView {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var oneAlertView: OneAlertView!
    let typeSubject = CurrentValueSubject<InternalTransferAccountSelectorHeaderType, Never>(.hidden)
    let viewFrameSubject = CurrentValueSubject<InternalTransferAccountSelectorHeaderType, Never>(.hidden)

    private var anySubscriptions = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews(type: .hidden)
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews(type: .hidden)
        bind()
    }
}

private extension InternalTransferAccountSelectorHeaderView {
    func getAlertTextKeyFor(type: InternalTransferAccountSelectorHeaderType) -> String {
        switch type {
        case .showHiddenAccounts:
            return "originAccount_label_infoWhithoutAccounts"
        case .showFilteredAccouts:
            return "originAccount_label_showAccountsOrigin"
        case .showHiddenAndFilteredAccounts:
            return "originAccount_label_hiddenAccountsOrigin"
        default:
            return ""
        }
    }
    
    func bind() {
        typeSubject
            .sink { [weak self] type in
                guard let self = self else { return }
                self.setupViews(type: type)
            }.store(in: &anySubscriptions)
    }
    
    func setupViews(type: InternalTransferAccountSelectorHeaderType) {
        imageView.image = Assets.image(named: "icnArrowSend")
        infoLabel.font = .typography(fontName: .oneH100Regular)
        infoLabel.textColor = .oneLisboaGray
        infoLabel.configureText(withKey: "originAccount_label_sentMoney")
        oneAlertView.setType(.textAndImage(imageKey: "icnInfo",stringKey: getAlertTextKeyFor(type: type)))
        oneAlertView.isHidden = type == .hidden
        setupAccessibilityInfo()
        viewFrameSubject.send(type)
    }
    
    func setupAccessibilityInfo() {
        infoLabel.accessibilityIdentifier = AccessibilitySendMoneyAccountSelector.infoLabel
        imageView.accessibilityIdentifier = AccessibilitySendMoneyAccountSelector.sentIcon
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = localized("voiceover_sendMoney")
        infoLabel.accessibilityLabel = localized("voiceover_listAccounts")
        oneAlertView.accessibilityLabel = localized("originAccount_label_infoWhithoutAccounts")
        oneAlertView.isAccessibilityElement = true
        oneAlertView.accessibilityTraits = .staticText
    }
}
