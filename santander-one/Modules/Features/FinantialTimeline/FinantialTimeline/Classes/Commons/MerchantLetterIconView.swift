//
//  MerchantLetterIcon.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 01/10/2019.
//

import UIKit

class MerchantLetterIcon: UIView {
    
    let iconLabel = UILabel()
    let merchantColors = TimelineCellMerchantColors.shared

    func setupIcon(event: TimeLineEvent) {
        configView()
        setMerchantColor(event: event)
        setFirstLetter(event: event)
    }
    
    func configView() {
        layer.cornerRadius = frame.height / 2
        backgroundColor = merchantColors.colors[0]
        
        addSubview(iconLabel)
        iconLabel.textColor = .white
        iconLabel.textAlignment = .center
        iconLabel.font = .santanderText(with: 20)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        iconLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        iconLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
    }
    
    func setMerchantColor(event: TimeLineEvent) {
        if let merchantName = event.merchant?.name {
            if merchantColors.merchantsSet.contains(merchantName) {
                backgroundColor = merchantColors.getColorFrom(merchant: merchantName)
            } else {
                backgroundColor = merchantColors.assignColorTo(merchant: merchantName)
            }
        }
    }
    
    func setFirstLetter(event: TimeLineEvent) {
        let firstLetter = event.merchant?.name?.prefix(1) ?? ""
        iconLabel.text = firstLetter.uppercased()
    }

}
