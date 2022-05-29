//
//  PendingSolicitudesCollapsedView.swift
//  GlobalPosition
//
//  Created by José Carlos Estela Anguita on 06/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol PendingSolicitudesCollapsedViewDelegate: AnyObject {
    func didSelectPendingSolicitudesCollapsedView()
}

final class PendingSolicitudesCollapsedView: UIView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var image: UIImageView!
    weak var delegate: PendingSolicitudesCollapsedViewDelegate?
    var view: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setTitleNumber(_ num: Int, style: CollapsedLabelStyle) {
        self.titleLabel.font = style.font
        self.titleLabel.textColor = style.color
        self.titleLabel.configureText(withLocalizedString: style.textWithNum(num))
    }
    
    @objc func didSelect() {
        self.delegate?.didSelectPendingSolicitudesCollapsedView()
    }
}

private extension PendingSolicitudesCollapsedView {
    
    func setupView() {
        self.xibSetup()
        self.view?.backgroundColor = .white
        self.titleLabel.setSantanderTextFont(type: .regular, size: 14, color: .lisboaGray)
        self.titleLabel.text = localized("contracts_label_pendingSignature")
        self.image.image = Assets.image(named: "icnArrowUpPendin")
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelect)))
    }
}

extension PendingSolicitudesCollapsedView: XibInstantiable {
    
    var bundle: Bundle? {
        return Bundle(for: PendingSolicitudesCollapsedView.self)
    }
}

enum CollapsedLabelStyle {
    case pendingRequest
    case recovery
    
    var font: UIFont {
        switch self {
        case .pendingRequest:
            return UIFont.santander(size: 14.0)
        case .recovery :
            return UIFont.santander(type: .bold, size: 16.0)
        }
    }
    
    var color: UIColor {
        switch self {
        default:
            return .lisboaGray
        }
    }
    
    func textWithNum(_ value: Int) -> LocalizedStylableText {
        switch self {
        case .pendingRequest:
            let key = value == 1 ? "contracts_label_pendingSignature_one" : "contracts_label_pendingSignature_other"
            return localized(key, [StringPlaceholder(.number, String(value))])
        case .recovery :
            let key = value == 1 ? "recoveredMoney_label_numPaymentSlip_one" : "recoveredMoney_label_numPaymentSlip_other"
            return localized(key, [StringPlaceholder(.number, String(value))])
        }
    }
}
