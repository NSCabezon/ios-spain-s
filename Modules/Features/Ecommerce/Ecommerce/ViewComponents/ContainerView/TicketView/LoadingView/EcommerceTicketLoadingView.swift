//
//  EcommerceTicketLoadingView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 17/3/21.
//

import UIKit
import UI

public final class EcommerceTicketLoadingView: XibView {

    @IBOutlet private weak var backgroundImageView: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension EcommerceTicketLoadingView {
    func setupView() {
        self.backgroundColor = .clear
        self.backgroundImageView.image = Assets.image(named: "ecommerceLoadingBackground")
        self.backgroundImageView.contentMode = .scaleAspectFit
    }
}
