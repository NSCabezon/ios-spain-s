//
//  LisboaClearView.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 22/06/2020.
//

import Foundation

public final class LisboaClearView: UIView {
    
    private let action: () -> Void
    private var style: LisboaTextFieldStyle
    
    init(action: @escaping () -> Void, style: LisboaTextFieldStyle) {
        self.action = action
        self.style = style
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.backgroundColor = self.style.backgroundColor
        let clearButton = UIButton()
        clearButton.setImage(Assets.image(named: "clearField"), for: .normal)
        self.addSubview(clearButton)
        clearButton.fullFit(topMargin: 16, bottomMargin: 16, leftMargin: 15, rightMargin: 15)
        clearButton.addTarget(self, action: #selector(executeAction), for: .touchUpInside)
        self.widthAnchor.constraint(equalToConstant: 47).isActive = true
    }
    
    @objc func executeAction() {
        self.action()
    }
}
