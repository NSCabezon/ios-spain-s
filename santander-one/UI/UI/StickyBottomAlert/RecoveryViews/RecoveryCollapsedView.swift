//
//  RecoveryCollapsedView.swift
//  UI
//
//  Created by alvola on 06/10/2020.
//

import UIKit
import CoreFoundationLib

public final class RecoveryCollapsedView: UIView {
    
    private lazy var arrowImage: UIImageView = {
        let image = UIImageView(image: Assets.image(named: "icnArrowUpPendin"))
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        return image
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.santander(type: .bold, size: 16.0)
        label.textColor = UIColor.lisboaGray
        addSubview(label)
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}
private extension RecoveryCollapsedView {
    func commonInit() {
        backgroundColor = .white
        configureLabel()
        configureArrow()
    }
    
    func configureLabel() {
        NSLayoutConstraint.activate([label.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0),
                                     label.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 12.5),
                                     label.heightAnchor.constraint(equalToConstant: 20.0)])
    }
    
    func configureArrow() {
        NSLayoutConstraint.activate([arrowImage.centerYAnchor.constraint(equalTo: label.centerYAnchor, constant: 2),
                                     arrowImage.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -8.0),
                                     arrowImage.heightAnchor.constraint(equalToConstant: 20.0),
                                     arrowImage.widthAnchor.constraint(equalToConstant: 21.0)])
    }
    
    func setDebtNum(_ num: Int) {
        let key = num == 1 ? "recoveredMoney_label_numPaymentSlip_one" : "recoveredMoney_label_numPaymentSlip_other"
        label.configureText(withLocalizedString: localized(key,
                                                           [StringPlaceholder(.value, String(num))]))
    }
}

extension RecoveryCollapsedView: StickyCollapsedViewProtocol {
    public func setInfo(_ info: Any) {
        guard let debt = info as? RecoveryViewModel else { return }
        setDebtNum(debt.debtCount)
    }
}
