//
//  InputCodeFacadeProtocol.swift
//  UI
//
//  Created by Angel Abad Perez on 20/12/21.
//

public protocol InputCodeFacadeProtocol: AnyObject {
    func view(with boxes: [InputCodeBoxView]) -> UIView
    func configuration() -> InputCodeFacadeConfiguration
}

public struct InputCodeFacadeConfiguration {
    let showPositions: Bool
    let showSecureEntry: Bool
    let elementsNumber: NSInteger
    let font: UIFont
    let cursorTintColor: UIColor
    let cursorHeight: CGFloat?
    let textColor: UIColor
    let borderColor: UIColor
    let borderWidth: CGFloat

    init(showPositions: Bool,
         showSecureEntry: Bool,
         elementsNumber: NSInteger,
         font: UIFont,
         cursorTintColor: UIColor = .santanderRed,
         cursorHeight: CGFloat? = nil,
         textColor: UIColor = .white,
         borderColor: UIColor = .clear,
         borderWidth: CGFloat = .zero) {
        self.showPositions = showPositions
        self.showSecureEntry = showSecureEntry
        self.elementsNumber = elementsNumber
        self.font = font
        self.cursorTintColor = cursorTintColor
        self.cursorHeight = cursorHeight
        self.textColor = textColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}
