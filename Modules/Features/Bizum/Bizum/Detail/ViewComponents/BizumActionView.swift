//
//  BizumActionView.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 12/11/2020.
//

import UI
import CoreFoundationLib
import ESUI

protocol BizumActionViewDelegate: class {
    func didTap(_ actionButton: BizumActionView, type: BizumActionType)
}

final class BizumActionView: XibView {
    
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var title: UILabel!
    private let type: BizumActionType
    
    weak var delegate: BizumActionViewDelegate?
    
    init(type: BizumActionType) {
        self.type = type
        super.init(frame: .zero)
        configView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTap() {
        delegate?.didTap(self, type: type)
    }
    
}

private extension BizumActionView {
    func configView() {
        clipsToBounds = true
        layer.cornerRadius = 5
        layer.borderWidth = 2
        layer.borderColor = UIColor.mediumSkyGray.cgColor
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(tapGesture)
        title.numberOfLines = 0
        title.textColor = .lisboaGray
        switch type {
        case .acceptRequest:
            configTitle("bizum_button_acceptRequest")
            icon.image = ESAssets.image(named: "icnSimpleTickRed17")
            accessibilityIdentifier = "bizum_button_acceptRequest"
            self.title.accessibilityIdentifier = (accessibilityIdentifier ?? "") + "LabelTitle"
        case .rejectRequest:
            configTitle("bizum_button_rejectRequest")
            icon.image = ESAssets.image(named: "icnCloseBostonRed")
            accessibilityIdentifier = "bizum_button_rejectRequest"
            self.title.accessibilityIdentifier = (accessibilityIdentifier ?? "") + "LabelTitle"
        case .cancelSend:
            configTitle("bizum_button_cancelShipping")
            icon.image = ESAssets.image(named: "icnCloseBostonRed")
            accessibilityIdentifier = "bizum_button_cancelShipping"
            self.title.accessibilityIdentifier = (accessibilityIdentifier ?? "") + "LabelTitle"
        case .sendAgain(let type):
            switch type {
            case .donation, .send, .purchase:
                configTitle("bizum_button_sendAgain")
            case .request:
                configTitle("bizum_label_requestAgain")
            case nil:
                break
            }
            icon.image = ESAssets.image(named: "icnUpdateRed")
            accessibilityIdentifier = "bizum_button_sendAgain"
            self.title.accessibilityIdentifier = (accessibilityIdentifier ?? "") + "LabelTitle"
        case .share:
            configTitle("generic_button_share")
            icon.image = Assets.image(named: "icnShareBostonRedLight")
            accessibilityIdentifier = "generic_button_share"
            self.title.accessibilityIdentifier = (accessibilityIdentifier ?? "") + "LabelTitle"
        case .reuseContact:
            configTitle("bizum_button_reuseContact")
            icon.image = ESAssets.image(named: "icnUserRed")
            accessibilityIdentifier = "bizum_button_reuseContact"
            self.title.accessibilityIdentifier = (accessibilityIdentifier ?? "") + "LabelTitle"
        case .refund:
            configTitle("bizum_button_returnShipping")
            icon.image = ESAssets.image(named: "icnReturnedOvalRed20")
            accessibilityIdentifier = "bizum_button_rejectRequest"
            self.title.accessibilityIdentifier = (accessibilityIdentifier ?? "") + "LabelTitle"
        case .cancelRequest:
            configTitle("bizum_button_cancelRequest")
            icon.image = ESAssets.image(named: "icnCloseBostonRed")
            accessibilityIdentifier = "bizum_button_cancelRequest"
            self.title.accessibilityIdentifier = (accessibilityIdentifier ?? "") + "LabelTitle"
        }
    }
    
    func configTitle(_ key: String) {
        let contactsNewSendSubtitleLabelConfig = LocalizedStylableTextConfiguration(font:
                                                                                            UIFont.santander(family: .text, type: .regular, size: 13),
                                                                                           textStyles: nil,
                                                                                           alignment: .center,
                                                                                           lineHeightMultiple: 0.75,
                                                                                           lineBreakMode: nil)
        title.configureText(withKey: key, andConfiguration: contactsNewSendSubtitleLabelConfig)
    }
}
