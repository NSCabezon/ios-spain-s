//
//  AtmMovementView.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 07/09/2020.
//

import Foundation
import CoreFoundationLib
import UI

final class AtmMovementView: XibView {
    
    @IBOutlet weak var dottedLineView: DottedLineView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup(movement: String, account: String, amount: NSAttributedString) {
        self.titleLabel?.font = .santander(family: .text, type: .regular, size: 16)
        self.titleLabel?.textColor = .lisboaGray
        self.titleLabel.text = movement
        self.accountLabel.text = account
        self.accountLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.accountLabel.textColor = .grafite
        self.amountLabel.font = .santander(family: .text, type: .bold, size: 20)
        self.amountLabel.textColor = .lisboaGray
        self.amountLabel.attributedText = amount
        self.view?.backgroundColor = .clear
    }
       
    func dottedHidden(isLast: Bool) {
        self.dottedLineView.isHidden = isLast
    }
}
