//
//  DesignableView.swift
//  toTest
//
//  Created by alvola on 27/09/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit

class DesignableView: UIView {
    
    @IBOutlet weak var contentView: UIView?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    internal func commonInit() {
        let nibName = String(describing: type(of: self))
        Bundle.module?.loadNibNamed(nibName, owner: self, options: nil)
        guard let content = contentView else { return }
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        content.backgroundColor = UIColor.clear
    }
}
