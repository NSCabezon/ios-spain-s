//
//  MonthTransfersDateSectionView.swift
//  Menu
//
//  Created by David Gálvez Alonso on 03/06/2020.
//

import CoreFoundationLib
import UI

class MonthTransfersDateSectionView: UITableViewHeaderFooterView {
        
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var fecha: UILabel!
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
        self.fecha.textColor = .bostonRed
        self.fecha.configureText(withLocalizedString: date,
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14)))
        self.separatorView.backgroundColor = UIColor.mediumSkyGray
    }
    
    func hideSeparator(_ hide: Bool) {
        self.separatorView.isHidden = hide
    }
}

private extension MonthTransfersDateSectionView {
    func setupView() {
        self.backgroundView = customBackground
    }
}
