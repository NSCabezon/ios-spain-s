//
//  DesignableView.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/27/20.
//

import Foundation

open class LegacyDesignableView: UIView {
    
    @IBOutlet open weak var contentView: UIView?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    open func commonInit() {
        let nibName = String(describing: type(of: self))
        self.bundle?.loadNibNamed(nibName, owner: self, options: nil)
        guard let content = contentView else { return }
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        content.backgroundColor = UIColor.clear
    }
    
    private var bundle: Bundle? {
        let bundle = Bundle(for: type(of: self))
        guard let identifier = bundle.bundleIdentifier else { return nil }
        return Bundle(identifier: identifier)
    }
}
