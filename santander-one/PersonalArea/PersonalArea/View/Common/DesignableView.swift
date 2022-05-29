//
//  DesignableView.swift
//  PersonalArea
//
//  Created by alvola on 11/11/2019.
//

import UIKit
import UI

class DesignableView: UIView {
    
    @IBOutlet weak var contentView: UIView?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
    }
    
    internal func internalInit() {
        let nibName = String(describing: type(of: self))
        Bundle.module?.loadNibNamed(nibName, owner: self, options: nil)
        guard let content = contentView else { return }
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
