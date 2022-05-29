//
//  HorizontalScrollableStackView.swift
//  UI
//
//  Created by alvola on 18/05/2020.
//

public final class HorizontalScrollableStackView: ScrollableStackView {
    public override func setup(with view: UIView) {
        self.stackView.axis = .horizontal
        super.setup(with: view)
    }
    
    public func enableScrollPagging(_ enable: Bool) {
        self.scrollView.isPagingEnabled = enable
    }
    
    internal override func setupStackView() {
        guard let view = self.view else { return }
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(self.stackView)
        NSLayoutConstraint.activate([
            self.stackView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor),
            self.stackView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.stackView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
}
