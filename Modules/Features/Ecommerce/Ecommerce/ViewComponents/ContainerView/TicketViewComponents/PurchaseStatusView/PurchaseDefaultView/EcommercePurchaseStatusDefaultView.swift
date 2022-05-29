//
//  EcommercePurchaseStatusDefaultView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 18/3/21.
//

import UIKit
import UI

public final class EcommercePurchaseStatusDefaultView: XibView {

    @IBOutlet private weak var statusImageView: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ status: EcommercePaymentStatus) {
        self.statusImageView.image = Assets.image(named: status.imageName())
    }
}

private extension EcommercePurchaseStatusDefaultView {
    func setupView() {
        self.backgroundColor = .clear
    }
}
