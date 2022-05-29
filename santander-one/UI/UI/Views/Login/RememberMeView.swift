//
//  RememberMeView.swift
//  toTest
//
//  Created by alvola on 27/09/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit

public protocol RememberMeViewDelegate: AnyObject {
    func checkButtonPressed()
}

public final class RememberMeView: LegacyDesignableView {
    
    @IBOutlet public weak var checkButton: UIButton?
    @IBOutlet public weak var label: UILabel?
    private weak var delegate: RememberMeViewDelegate?

    override public func commonInit() {
        super.commonInit()
        
        contentView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewPressed)))
        contentView?.isUserInteractionEnabled = true
        
        label?.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        label?.textColor = UIColor.Legacy.uiWhite
        
        checkButton?.isSelected = true
        checkButton?.setImage(Assets.image(named: "icnCheckWhite"), for: .selected)
        checkButton?.setImage(Assets.image(named: "icnCheckbox"), for: .normal)
    }
    
    public func setTitle(_ text: String) { label?.text = text }
    
    public func remember() -> Bool { return checkButton?.isSelected ?? false }
    
    public func setDelegate(_ delegate: RememberMeViewDelegate) { self.delegate = delegate }
    
    @objc private func viewPressed() {
        checkButton?.isSelected = !(checkButton?.isSelected ?? true)
        delegate?.checkButtonPressed()
    }
    
    public func setText(_ text: String, selected: Bool = false) {
        label?.text = text
        checkButton?.isSelected = selected
    }
}
