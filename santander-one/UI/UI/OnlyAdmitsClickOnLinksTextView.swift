//
//  OnlyAdmitsClickOnLinksTextView.swift
//  UI
//
//  Created by Ernesto Fernandez Calles on 15/4/21.
//

import UIKit

final public class OnlyAdmitsClickOnLinksTextView: UITextView {
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let pos = closestPosition(to: point) else { return false }
        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: .layout(.left)) else { return false }
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }
}
