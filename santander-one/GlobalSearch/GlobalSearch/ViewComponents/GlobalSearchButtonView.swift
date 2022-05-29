//
//  GlobalSearchButtonView.swift
//  GlobalSearch
//
//  Created by César González Palomino on 25/02/2020.
//

import UI
import CoreFoundationLib

protocol GlobalSearchButtonViewDelegate: class {
    func didSelect(button: GlobalSearchButtonView, withAction action: GlobalSearchButtonAction)
}

enum GlobalSearchButtonAction {
    case reportDuplicate
    case returnReceipt
    case reuseTransfer
    case turnOffCard
    
    var iconName: String {
        switch self {
        case .reportDuplicate: return "icnReportDuplicate"
        case .returnReceipt: return "icnReturnReceipt"
        case .reuseTransfer: return "icnReuseTransfer"
        case .turnOffCard: return "icn_off"
        }
    }
    
    var title: String {
        switch self {
        case .reportDuplicate: return "transaction_buttonOption_reportDuplicate"
        case .returnReceipt: return "transaction_buttonOption_returnedReceipt"
        case .reuseTransfer: return "transaction_buttonOption_reuseTransfer"
        case .turnOffCard: return "transaction_buttonOption_cardOff"
        }
    }
    
    var shouldFlip: Bool {
        return self == .reportDuplicate
    }
}

final class GlobalSearchButtonView: XibView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var phoneImageView: UIImageView!
    weak var delegate: GlobalSearchButtonViewDelegate?
    private let action: GlobalSearchButtonAction
    
    var isFlipped = false
    
    init(action: GlobalSearchButtonAction) {
        self.action = action
        super.init(frame: .zero)
        self.configureLabels()
    }
    
    override init(frame: CGRect) {
        self.action = .reportDuplicate
        super.init(frame: frame)
        self.configureLabels()
    }
    
    required init?(coder: NSCoder) {
        self.action = .reportDuplicate
        super.init(coder: coder)
        self.configureLabels()
    }
    
    func configureLabels() {
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        contentView.layer.shadowRadius = 2.0
        contentView.layer.shadowOpacity = 1.0
        contentView.layer.shadowColor = UIColor(white: 213.0 / 255.0, alpha: 1.0).cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.masksToBounds = false
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                action: #selector(touch)))
        
        titleLabel.textColor = .lisboaGray
        titleLabel.font = .santander(family: .text, type: .regular, size: 16.0)
        titleLabel.set(localizedStylableText: localized(action.title))
        
        iconImageView.image = Assets.image(named: action.iconName)
        phoneImageView.image = action.shouldFlip ?  Assets.image(named: "icnCornerPhone3") : nil
    }
    
    @objc func touch() {
        delegate?.didSelect(button: self, withAction: action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        contentView?.layer.shadowRadius = 4.0
        contentView?.layer.shadowOpacity = 1.0
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        contentView?.layer.shadowRadius = 2.0
        contentView?.layer.shadowOpacity = 0.3
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        contentView.layer.shadowRadius = 2.0
        contentView.layer.shadowOpacity = 0.3
    }
}
