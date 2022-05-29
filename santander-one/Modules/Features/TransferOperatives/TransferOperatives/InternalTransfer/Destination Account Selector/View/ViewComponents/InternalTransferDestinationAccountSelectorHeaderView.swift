//
//  InternalTransferDestinationAccountSelectorHeaderView.swift
//  TransferOperatives
//
//  Created by Juan Sánchez Marín on 17/2/22.
//

import UI
import UIOneComponents
import CoreFoundationLib
import OpenCombine
import CoreDomain

public enum InternalTransferDestinationAccountSelectorHeaderType {
    case hidden
    case showHiddenAccounts
    case showFilteredAccouts
    case showHiddenAndFilteredAccounts
}

final class InternalTransferDestinationAccountSelectorHeaderView: XibView {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var oneAlertView: OneAlertView!
    @IBOutlet weak var oneAccountSelectedCardView: OneAccountsSelectedCardView!
    let typeSubject = CurrentValueSubject<(InternalTransferDestinationAccountSelectorHeaderType), Never>((.hidden))
    let viewFrameSubject = CurrentValueSubject<InternalTransferDestinationAccountSelectorHeaderType, Never>(.hidden)
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

private extension InternalTransferDestinationAccountSelectorHeaderView {
    func getAlertTextKeyFor(type: InternalTransferDestinationAccountSelectorHeaderType) -> String {
        switch type {
        case .showHiddenAccounts:
            return "originAccount_label_infoWhithoutAccounts"
        case .showFilteredAccouts:
            return "destinationAccount_label_showAccountsDestination"
        case .showHiddenAndFilteredAccounts:
            return "destinationAccount_label_hiddenAccountsDestination"
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

    func setupSelectedAccount(viewModel: OneAccountsSelectedCardViewModel) {
        self.oneAccountSelectedCardView.setupAccountViewModel(viewModel)
    }

    func setupViews(type: InternalTransferDestinationAccountSelectorHeaderType) {
        imageView.image = Assets.image(named: "oneIcnArrowReceive")
        infoLabel.font = .typography(fontName: .oneH100Regular)
        infoLabel.textColor = .oneLisboaGray
        infoLabel.configureText(withKey: "destinationAccounts_label_receiveMoney")
        oneAlertView.setType(.textAndImage(imageKey: "icnInfo",stringKey: getAlertTextKeyFor(type: type)))
        oneAlertView.isHidden = type == .hidden
        setupAccessibilityInfo()
        viewFrameSubject.send(type)
    }

    func setupAccessibilityInfo() {
        infoLabel.accessibilityIdentifier = AccessibilitySendMoneyDestinattionAccountSelector.infoLabel
        imageView.accessibilityIdentifier = AccessibilitySendMoneyDestinattionAccountSelector.receiveIcon
    }
}
