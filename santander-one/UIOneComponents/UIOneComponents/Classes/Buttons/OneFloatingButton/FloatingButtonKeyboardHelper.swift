//
//  FloatingButtonKeyboardHelper.swift
//  UIOneComponents
//
//  Created by David Gálvez Alonso on 8/11/21.
//

import UIKit
import UI

public protocol FloatingButtonKeyboardHelper: UIViewController {
    var contentScrollView: UIScrollView! { get set }
    var floatingButton: OneFloatingButton! { get set }
    var floatingButtonConstraint: NSLayoutConstraint! { get set }
}

public extension FloatingButtonKeyboardHelper {
    private var floatingConstraint: CGFloat {
        return 24
    }
    
    func keyboardWillShowWithFloatingButton(_ notification: Notification) {
        let userInfo = notification.userInfo
        guard let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
                  return
              }
        let keyboardHeight = keyboardSize.cgRectValue.height
        var contentInset = self.contentScrollView.contentInset
        contentInset.bottom = keyboardHeight + (self.floatingConstraint * 4) + self.floatingButton.frame.height
        self.contentScrollView.contentInset = contentInset
        self.floatingButtonConstraint.constant = self.floatingConstraint + keyboardHeight
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseIn]) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHideWithFloatingButton(_ notification: Notification) {
        self.contentScrollView.contentInset = .zero
        self.floatingButtonConstraint.constant = self.floatingConstraint
    }
}
