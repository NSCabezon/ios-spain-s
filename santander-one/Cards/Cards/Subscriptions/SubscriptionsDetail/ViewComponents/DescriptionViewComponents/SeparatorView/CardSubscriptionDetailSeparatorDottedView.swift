//
//  CardSubscriptionDetailSeparatorDottedView.swift
//  Cards
//
//  Created by Ignacio González Miró on 8/4/21.
//

import UIKit
import UI

public final class CardSubscriptionDetailSeparatorDottedView: XibView {
    @IBOutlet private weak var separatorView: UIView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        separatorView.dotted(with: [1, 1, 1, 1], color: UIColor.lightSanGray.cgColor)
    }

}
private extension CardSubscriptionDetailSeparatorDottedView {
    func setupView() {
        backgroundColor = .clear
    }
}
