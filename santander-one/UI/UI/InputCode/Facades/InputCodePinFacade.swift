//
//  InputCodePinFacade.swift
//  UI
//
//  Created by Angel Abad Perez on 20/12/21.
//

import UIKit

public final class InputCodePinFacade {
    public init() {}

    private enum Constants {
        static var elementsNumber = 4
        static let elementWidth: CGFloat = 43.0
        static let elementHeight: CGFloat = 48.0
        static let spacingBetweenColumns: CGFloat = .zero
        static let font = UIFont.systemFont(ofSize: 30)
        static let cursorTintColor = UIColor.lisboaGray
        static let cursorHeight: CGFloat = 17.0
        static let textTintColor = UIColor.darkTorquoise
        static let borderColor = UIColor.brownGray
        static let borderWidth: CGFloat = 1.0
        static let cornerRadius: CGFloat = 6.0
    }

    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Constants.spacingBetweenColumns
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
}

extension InputCodePinFacade: InputCodeFacadeProtocol {
    public func view(with boxes: [InputCodeBoxView]) -> UIView {
        for position in 1...boxes.count {
            self.horizontalStackView.addArrangedSubview(boxes[position-1])
            boxes[position-1].backgroundColor = .white
            if position == 1 {
                boxes[position-1].configureCorners(corners: [.topLeft, .bottomLeft], radius: Constants.cornerRadius)
            }
            if position == boxes.count {
                boxes[position-1].configureCorners(corners: [.topRight, .bottomRight], radius: Constants.cornerRadius)
            }
         }
         let container = UIView()
         container.addSubview(horizontalStackView)
         container.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
            horizontalStackView.widthAnchor.constraint(equalToConstant: getControlLength()),
            horizontalStackView.heightAnchor.constraint(equalToConstant: Constants.elementHeight),
            horizontalStackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            horizontalStackView.topAnchor.constraint(equalTo: container.topAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
         ])
         return container
    }

    public func configuration() -> InputCodeFacadeConfiguration {
        return InputCodeFacadeConfiguration(showPositions: false,
                                            showSecureEntry: true,
                                            elementsNumber: Constants.elementsNumber,
                                            font: Constants.font,
                                            cursorTintColor: Constants.cursorTintColor,
                                            cursorHeight: Constants.cursorHeight,
                                            textColor: Constants.textTintColor,
                                            borderColor: Constants.borderColor,
                                            borderWidth: Constants.borderWidth)
    }

    private func getControlLength() -> CGFloat {
        let boxesLength = CGFloat(Constants.elementsNumber) * Constants.elementWidth
        let spaceLength = Constants.spacingBetweenColumns * CGFloat(Constants.elementsNumber - 1)
        let controlLength = boxesLength + spaceLength
        return CGFloat(controlLength)
    }
    
    public func setConstants(elementsNumber: Int) {
        Constants.elementsNumber = elementsNumber
    }
}
