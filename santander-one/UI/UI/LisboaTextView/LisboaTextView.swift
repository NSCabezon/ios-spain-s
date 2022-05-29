//
//  LisboaTextView.swift
//  UI
//
//  Created by Cristobal Ramos Laina on 09/12/2020.
//

import Foundation
import CoreFoundationLib
import UIKit

public final class LisboaTextView: XibView, UITextViewDelegate {
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var separatorView: UIView!
    private var placeholder: String?
    public var maxCharacters = 250
    public var allowOnlyCharacterSet = CharacterSet.operative

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func getText() -> String? {
        if self.textView.text == self.placeholder {
            return nil
        } else {
            return self.textView.text
        }
    }
    
    public func setupView(placeholder: String?) {
        self.placeholder = placeholder ?? ""
        self.textView.text = self.placeholder
        self.textView.textFont = .santander(family: .text, type: .regular, size: 16)
        self.textView.textColor = UIColor.mediumSanGray
        self.view?.backgroundColor = .clear
        self.textView.backgroundColor = .skyGray
        self.view?.layer.borderWidth = 1
        self.view?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.textView.delegate = self
        self.separatorView.backgroundColor = .darkTurqLight
        
    }
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == self.placeholder {
            textView.text = ""
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = self.placeholder
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        guard characterSetOk(text) else { return false }
        return numberOfChars < self.maxCharacters
    }
    
    func characterSetOk(_ string: String) -> Bool {
        let character = CharacterSet(charactersIn: string)
        return allowOnlyCharacterSet.isSuperset(of: character)
    }
}
