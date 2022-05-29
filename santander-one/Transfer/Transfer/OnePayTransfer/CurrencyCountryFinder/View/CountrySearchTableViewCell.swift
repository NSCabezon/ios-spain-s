//
//  CountrySearchTableViewCell.swift
//  Transfer
//
//  Created by Boris Chirino Fernandez on 25/05/2020.
//

import UI
import CoreFoundationLib

final class CountrySearchTableViewCell: UITableViewCell {
    static let identifier = "CountrySearchTableViewCell"
    public func configureWithItem(_ item: CountryItemViewModel) {
        self.textLabel?.setSantanderTextFont(type: .regular, size: 16, color: .lisboaGray)
        self.textLabel?.configureText(withKey: item.name)
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        if selected == true {
            self.textLabel?.font = .santander(family: .text, type: .bold, size: 16)
            self.textLabel?.textColor = .darkTorquoise
        }
    }
}
