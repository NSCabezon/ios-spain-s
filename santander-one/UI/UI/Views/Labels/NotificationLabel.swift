//
//  NotificationLabel.swift
//  UI
//
//  Created by alvola on 30/10/2019.
//

import UIKit

public class NotificationLabel: UILabel {
    
    let LIMIT = 99
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
    }
    
    public func setNotificationNum(_ num: Int?) {
        guard let num = num, num != 0 else { text = nil; return }
        text = num > LIMIT ? ("+" + String(LIMIT)) : String(num)
    }
    
    func commonInit() {
        backgroundColor = UIColor.santanderRed
        clipsToBounds = true
        textColor = UIColor.white
        font = UIFont.santander(family: .text, type: .bold, size: 12.0)
    }
}
