//
//  NSAttributedString+Extension.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 10/15/19.
//

import Foundation

extension NSAttributedString {
    func rangeOf(string: String) -> Range<String.Index>? {
        return self.string.range(of: string)
    }
    
    func getTextSize() -> CGSize {
        let testLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 0, height: 0))
        testLabel.attributedText = self
        testLabel.sizeToFit()
        return testLabel.frame.size
    }
}
