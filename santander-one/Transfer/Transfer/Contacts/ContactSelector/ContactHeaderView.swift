//
//  ContactHeaderView.swift
//  Alamofire
//
//  Created by Cristobal Ramos Laina on 07/02/2020.
//

import Foundation
import UIKit
import CoreFoundationLib
import UI

class ContactHeaderView: XibView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setup() {
        self.imageView?.image = Assets.image(named: "icnAddressee")
        self.titleLabel?.text = localized("favoriteRecipients_label_sendMoney")
        self.titleLabel?.textColor = .gray
        titleLabel?.font = .santander(family: .text, type: .light, size: 14.0)
    }
}
