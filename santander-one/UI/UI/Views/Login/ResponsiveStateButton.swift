//
//  ResponsiveStateButton.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/30/20.
//

import Foundation

open class ResponsiveStateButton: StateButton {
    public var onTouchAction: ((_ sender: ResponsiveStateButton) -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
    
    public func build() {
        addTarget(self, action: #selector(didTouch(sender:)), for: .touchUpInside)
    }
    
    @objc
    open func didTouch(sender: ResponsiveStateButton) {
        onTouchAction?(self)
    }
}
