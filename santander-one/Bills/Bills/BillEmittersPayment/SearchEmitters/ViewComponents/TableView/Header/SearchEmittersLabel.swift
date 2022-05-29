//
//  SearchEmittersLabel.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/21/20.
//

import Foundation
import UI

final class SearchEmittersLabel: XibView {
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setLocalizedKey(_ key: String) {
        self.descriptionLabel.configureText(withKey: key)
    }
}
