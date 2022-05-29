//
//  BlueLineView.swift
//  UI
//
//  Created by Juan Carlos López Robles on 12/5/19.
//

import UIKit
import CoreFoundationLib

public class BlueLineView: UIView {
    public enum Position {
        case top, boottom
    }
    
    var position: Position = .top
    
    public convenience init(position: Position) {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.mediumSkyGray
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addViewConstraint()
        self.addViewToPosition()
    }
    
    private func addViewConstraint() {
        guard let container = superview else { return }
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 1),
            widthAnchor.constraint(equalTo: container.widthAnchor)
        ])
    }
    
    private func addViewToPosition() {
        guard let container = superview else { return }
        switch position {
        case .top:
            topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        case .boottom:
            topAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        }
    }
}
