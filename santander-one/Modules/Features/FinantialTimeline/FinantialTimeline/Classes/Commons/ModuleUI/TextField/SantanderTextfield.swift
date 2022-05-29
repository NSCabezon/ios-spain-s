//
//  SantanderTextfield.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

class SantanderTextfield: UITextField {
    @IBInspectable open var required: Bool = false
    @IBInspectable open var minLenght: Int = 0
    @IBInspectable open var maxLenght: Int = 120
    @IBInspectable open var regex: String = ""
    @IBInspectable open var alias: String = ""
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addNotification()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addNotification()
    }
    
    deinit {
        self.removeRegisterDidChangeNotification()
    }

    func addNotification() {
        self.registerDidChangeNotification()
    }
    
    fileprivate func registerDidChangeNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"),
                                               object: self)
    }
    
    fileprivate func removeRegisterDidChangeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func textDidChange() {
        self.undoManager?.removeAllActions()
    }
}
