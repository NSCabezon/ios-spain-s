//
//  DetailButtonsSectionTableView.swift
//  LocatorApp
//
//  Created by vectoradmin on 27/8/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit

protocol DetailSectionTableProtocol: NSObjectProtocol {
    func buttonPressed(left: Bool)
}

class DetailButtonsSectionTableView: UIView {
	
    @IBOutlet var topSeperatorView: UIView!{
        didSet {
            topSeperatorView.backgroundColor = DetailButtonsSectionTableViewColor.bottomSeperatorView.value
        }
    }
    
    @IBOutlet weak var bottomSeparatorView: UIView! {
		didSet {
			bottomSeparatorView.backgroundColor = DetailButtonsSectionTableViewColor.bottomSeperatorView.value
		}
	}
    
    @IBOutlet weak var leftView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(leftAction))
            leftView.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var leftLabel: UILabel! {
        didSet {
            leftLabel.text = localizedString("bl_branch")
        }
    }
    @IBOutlet weak var leftLedView: UIView! {
        didSet {
            leftLedView.backgroundColor = UIColor.santanderRed
        }
    }
    
    @IBOutlet var leftUnderlineView: UIView!
    
    @IBOutlet weak var centerView: UIView! {
        didSet {
            centerView.backgroundColor = DetailButtonsSectionTableViewColor.centerView.value
        }
    }
    
    @IBOutlet weak var rightView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(rightAction))
            rightView.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var rightLabel: UILabel! {
        didSet {
            rightLabel.text = localizedString("bl_atm")
        }
    }
    @IBOutlet weak var rightLedView: UIView! {
        didSet {
            rightLedView.backgroundColor = UIColor.red
        }
    }
    
    @IBOutlet var rightUnderlineView: UIView!
    
    var optionSelected: Type = .branch
	
	func configureView(main: Bool) {
        self.backgroundColor = .white
        self.leftView.backgroundColor = .white
        self.centerView.backgroundColor = .mediumSky
		if main {
			setLeftView(isOn: true)
			setRightView(isOn: false)
		} else {
			setLeftView(isOn: false)
			setRightView(isOn: true)
		}
	}
    
    weak var delegate: DetailSectionTableProtocol?
    
    @objc func leftAction() {
        optionSelected = .branch
        delegate?.buttonPressed(left: true)
        setLeftView(isOn: true)
        setRightView(isOn: false)
    }
    
    @objc func rightAction() {
        optionSelected = .atm
        delegate?.buttonPressed(left: false)
        setLeftView(isOn: false)
        setRightView(isOn: true)
    }
    
    func setRightView(isOn: Bool) {
        if isOn {
            self.rightLabel.font = DetailButtonsSectionTableViewFont.rightLeftLabelsSelected.value
            self.rightLabel.textColor = DetailButtonsSectionTableViewColor.rightLeftLabelsSelected.value
            self.rightLedView.isHidden = false
            self.rightUnderlineView.isHidden = false
        } else {
            self.rightLabel.font = DetailButtonsSectionTableViewFont.rightLeftLabelsUnselected.value
            self.rightLabel.textColor = DetailButtonsSectionTableViewColor.rightLeftLabelsUnselected.value
            self.rightLedView.isHidden = true
            self.rightUnderlineView.isHidden = true
        }

    }
    
    func setLeftView(isOn: Bool) {
        if isOn {
            self.leftLabel.font = DetailButtonsSectionTableViewFont.rightLeftLabelsSelected.value
            self.leftLabel.textColor = DetailButtonsSectionTableViewColor.rightLeftLabelsSelected.value
            self.leftLedView.isHidden = false
            self.leftUnderlineView.isHidden = false
        } else {
            self.leftLabel.font = DetailButtonsSectionTableViewFont.rightLeftLabelsUnselected.value
            self.leftLabel.textColor = DetailButtonsSectionTableViewColor.rightLeftLabelsUnselected.value
            self.leftLedView.isHidden = true
            self.leftUnderlineView.isHidden = true
        }
    }

}
