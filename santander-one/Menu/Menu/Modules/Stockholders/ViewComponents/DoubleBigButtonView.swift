//
//  DoubleBigButtonView.swift
//  Menu
//
//  Created by alvola on 28/04/2020.
//

import UIKit
import CoreDomain

public protocol DoubleBigButtonViewDelegate: AnyObject {
    func didSelect(_ idx: Int)
}

public final class DoubleBigButtonView: UIView {
    
    private lazy var leftButton: BigButtonOldView = {
        let button = BigButtonOldView(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        return button
    }()
    
    private lazy var rightButton: BigButtonOldView = {
        let button = BigButtonOldView(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        return button
    }()
    
    private var leftIdx: Int?
    private var rightIdx: Int?
    
    public weak var delegate: DoubleBigButtonViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func setLeftInfo(leftSide: (model: ButtonViewModel, type: BigButtonOldType)?,
                            rightSide: (model: ButtonViewModel, type: BigButtonOldType)?) {
        if let leftSide = leftSide {
            leftButton.setInfo(leftSide.model, withType: leftSide.type)
        } else {
            leftButton.isHidden = true
        }
        if let rightSide = rightSide {
            rightButton.setInfo(rightSide.model, withType: rightSide.type)
        } else {
            rightButton.isHidden = true
        }
    }
    
    public func setLeftIndex(_ leftIndex: Int?, rightIndex: Int?) {
        leftButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftTouchUpInside)))
        rightButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightTouchUpInside)))
        leftIdx = leftIndex
        rightIdx = rightIndex
    }
}

private extension DoubleBigButtonView {
    func commonInit() {
        addLeftConstraints()
        addRightConstraints()
    }
    
    func addLeftConstraints() {
        leftButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 4.0).isActive = true
        self.bottomAnchor.constraint(equalTo: leftButton.bottomAnchor, constant: 4.0).isActive = true
        leftButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0).isActive = true
        self.centerXAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: 4.0).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 120.0).isActive = true
    }
    
    func addRightConstraints() {
        rightButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 4.0).isActive = true
        self.bottomAnchor.constraint(equalTo: rightButton.bottomAnchor, constant: 4.0).isActive = true
        rightButton.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 4.0).isActive = true
        self.trailingAnchor.constraint(equalTo: rightButton.trailingAnchor, constant: 16.0).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: 120.0).isActive = true
    }
    
    @objc func leftTouchUpInside() {
        if let leftIdx = leftIdx {
            delegate?.didSelect(leftIdx)
        }
    }
    
    @objc func rightTouchUpInside() {
        guard let rightIdx = rightIdx else { return }
        delegate?.didSelect(rightIdx)
    }
}
