//
//  SheetScrollableContent.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/2/20.
//

import Foundation
import UIKit

public class SheetScrollableContent: UIView {
    private var scrollView = SheetScrollView()
    private var view: UIView?
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup(with view: UIView) {
        self.view = view
        self.view?.addSubview(scrollView)
        self.setupScrollView()
        self.setupStackView()
        self.backgroundColor = .clear
    }
    
    public func addArrangedSubview(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }
    
    func getArrangedSubviews() -> [UIView] {
        return self.stackView.arrangedSubviews
    }
    
    func setSpacing(_ spacing: CGFloat) {
        self.stackView.spacing = spacing
    }
}

private extension SheetScrollableContent {
    func setupScrollView() {
          self.scrollView.backgroundColor = .clear
          self.scrollView.showsHorizontalScrollIndicator = false
          self.scrollView.showsVerticalScrollIndicator = false
          self.scrollView.translatesAutoresizingMaskIntoConstraints = false
          self.addScrollConstraints()
      }
      
    func addScrollConstraints() {
          guard let view = self.view else { return }
          NSLayoutConstraint.activate([
              self.scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
              self.scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
              self.scrollView.topAnchor.constraint(equalTo: view.topAnchor),
              self.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
              self.scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
              self.scrollView.heightAnchor.constraint(equalToConstant: 1)
          ])
      }
      
    func setupStackView() {
          guard let view = self.view else { return }
          self.stackView.translatesAutoresizingMaskIntoConstraints = false
          self.scrollView.addSubview(self.stackView)
          NSLayoutConstraint.activate([
              self.stackView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor),
              self.stackView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor),
              self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
              self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
              self.stackView.widthAnchor.constraint(equalTo: view.widthAnchor)
          ])
      }
}

final class SheetScrollView: UIScrollView {
    var bottomSpacing: CGFloat {
        guard Screen.isScreenSizeBiggerThanIphone8plus() else {
            return 19
        }
        return 40
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.constraints
            .first(where: {$0.firstAttribute == .height})?
            .constant = self.contentSize.height + bottomSpacing
    }
}
