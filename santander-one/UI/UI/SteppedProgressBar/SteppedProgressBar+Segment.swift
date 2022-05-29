//
//  SteppedProgressBar+Segment.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 16/07/2020.
//

import UIKit

extension SteppedProgressBar {
    
    class Segment: UIView {
        
        private let filledView: UIView
        private let unfilledView: UIView
        private lazy var filledWidth: NSLayoutConstraint = {
            return self.filledView.widthAnchor.constraint(equalToConstant: 0)
        }()
        private let progressBarType: ProgressBarType
        
        init(filledColor: UIColor, unfilledColor: UIColor, progressBarType: ProgressBarType) {
            self.filledView = UIView()
            self.filledView.translatesAutoresizingMaskIntoConstraints = false
            self.filledView.backgroundColor = filledColor
            self.unfilledView = UIView()
            self.unfilledView.translatesAutoresizingMaskIntoConstraints = false
            self.unfilledView.backgroundColor = unfilledColor
            self.progressBarType = progressBarType
            super.init(frame: .zero)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        func moveForward(animated: Bool, completion: @escaping () -> Void) {
            self.filledWidth.constant = self.unfilledView.frame.size.width
            guard animated == true else {
                self.layoutSubviews()
                return completion()
            }
            self.animate(completion: completion)
        }
        
        func moveBackward(animated: Bool, completion: @escaping () -> Void) {
            self.filledWidth.constant = 0
            guard animated == true else {
                self.layoutSubviews()
                return completion()
            }
            self.animate(completion: completion)
        }
        
        private func animate(completion: @escaping () -> Void) {
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.layoutSubviews()
                },
                completion: { finished in
                    guard finished else { return }
                    completion()
                }
            )
        }
        
        private func setup() {
            self.addUnfilledView()
            self.addFilledView()
        }
        
        private func addFilledView() {
            self.addSubview(self.filledView)
            self.filledView.leftAnchor.constraint(equalTo: self.unfilledView.leftAnchor).isActive = true
            self.filledView.topAnchor.constraint(equalTo: self.unfilledView.topAnchor).isActive = true
            self.filledView.bottomAnchor.constraint(equalTo: self.unfilledView.bottomAnchor).isActive = true
            self.filledWidth.isActive = true
        }
        
        private func addUnfilledView() {
            self.addSubview(self.unfilledView)
            self.unfilledView.fullFit(
                topMargin: self.progressBarType.segmentMargin,
                bottomMargin: self.progressBarType.segmentMargin
            )
        }
    }
}
