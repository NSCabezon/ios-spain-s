//
//  LastMovementsSection.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 16/07/2020.
//

import UIKit
import UI
import CoreFoundationLib

class LastMovementsSection: UITableViewHeaderFooterView {
        
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var dateLabel: UILabel!
    
    static let identifier = "LastMovementsSection"
    
    private lazy var customBackground: UIView = {
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        return backgroundView
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        gestureRecognizers?.forEach({ removeGestureRecognizer($0) })
        super.addGestureRecognizer(gestureRecognizer)
    }
    
    func configure(withDate date: LocalizedStylableText) {
        self.dateLabel.textColor = .bostonRed
        self.dateLabel.font = .santander(family: .text, type: .bold, size: 14)
        self.dateLabel.configureText(withLocalizedString: date)
        self.separatorView.backgroundColor = UIColor.mediumSkyGray
    }
    
    func hideSeparator(_ hide: Bool) {
        self.separatorView.isHidden = hide
    }
}

private extension LastMovementsSection {
    func setupView() {
        self.backgroundView = customBackground
    }
}
