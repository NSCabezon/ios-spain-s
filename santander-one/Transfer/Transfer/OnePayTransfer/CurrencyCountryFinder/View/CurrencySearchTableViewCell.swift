//
//  CountrySearchTableViewCell.swift
//  Transfer
//
//  Created by Boris Chirino Fernandez on 25/05/2020.
//

import UI
import CoreFoundationLib

public final class CurrencySearchTableViewCell: UITableViewCell {
    static let identifier = "CurrencySearchTableViewCell"
    public func configureWithItem(_ item: CurrencyItemViewModel) {
        let itemCode = " (" + item.code + ")"
        let wholeText = item.name + itemCode
        let builder = TextStylizer.Builder(fullText: wholeText)
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: item.name)
                            .setStyle(.santander(family: .text, type: .regular, size: 16.0))
                            .setColor(.lisboaGray))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: itemCode)
                            .setStyle(.santander(family: .text, type: .regular, size: 14.0))
                            .setColor(.mediumSanGray))
        self.textLabel?.attributedText = builder.build()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        if selected == true {
            self.textLabel?.font = .santander(family: .text, type: .bold, size: 16)
            self.textLabel?.textColor = .darkTorquoise
        }
    }
}
