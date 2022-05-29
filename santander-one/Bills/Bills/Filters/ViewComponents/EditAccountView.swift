//
//  EditAccountView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/21/20.
//

import Foundation
import UI
import CoreFoundationLib

final class EditAccountView: XibView {
    @IBOutlet weak var editImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.appearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.appearance()
    }
}

private extension EditAccountView {
    func appearance() {
        self.view?.backgroundColor = .clear
        self.editImage.image = Assets.image(named: "icnEdit")
        self.accessibilityIdentifier = "btnEdit"
    }
}
