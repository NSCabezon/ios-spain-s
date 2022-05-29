//
//  EcommerceSeparatorView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 17/3/21.
//

import UIKit
import UI

public final class EcommerceSeparatorView: XibView {

    @IBOutlet private weak var separatorView: DashedLineView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension EcommerceSeparatorView {
    func setupView() {
        self.backgroundColor = .clear
        self.separatorView.backgroundColor = .clear
        self.separatorView.strokeColor = .brownGray
        self.separatorView.dashPattern = [9, 2]
    }
}
