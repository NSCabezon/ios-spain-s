//
//  TextField+Extension.swift
//  UIOneComponents
//
//  Created by Adrian Arcalá Ocón on 14/12/21.
//

import Foundation
import CoreFoundationLib

extension UITextField {
    func setToolbarDoneButton(completion: @escaping () -> ()) -> UIToolbar? {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: 0,
                                                             height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: localized("generic_label_done"), style: .done, action: completion)
        doneButton.tintColor = .oneBostonRed
        doneButton.accessibilityLabel = doneButton.title
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(doneButton)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        return doneToolbar
    }
}

fileprivate var actionKey: Void?

extension UIBarButtonItem {

    private var action: () -> () {
        get {
            return objc_getAssociatedObject(self, &actionKey) as! () -> ()
        }
        set {
            objc_setAssociatedObject(self, &actionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public convenience init(title: String?, style: UIBarButtonItem.Style , action: @escaping () -> ()) {
        self.init(title: title, style: style, target: nil, action: #selector(pressed))
        self.target = self
        self.action = action
    }

    @objc private func pressed(sender: UIBarButtonItem) {
        self.action()
    }

}
