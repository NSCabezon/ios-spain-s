//
//  EasyPayYearSeparatorView.swift
//  Cards
//
//  Created by alvola on 10/12/2020.
//

final class EasyPayYearSeparatorView: UIView {
    
    private lazy var leftSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .mediumSkyGray
        addSubview(view)
        return view
    }()
    
    private lazy var yearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = .lisboaGray
        label.font = UIFont.santander(size: 16.0)
        addSubview(label)
        return label
    }()
    
    private lazy var rightSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .mediumSkyGray
        addSubview(view)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setYear(_ year: String) {
        yearLabel.text = year
    }
}

private extension EasyPayYearSeparatorView {
    func setup() {
        leftSeparatorConstraints()
        yearLabelConstraints()
        rightSeparatorConstraints()
    }
    
    func leftSeparatorConstraints() {
        NSLayoutConstraint.activate([
            leftSeparator.centerYAnchor.constraint(equalTo: yearLabel.centerYAnchor),
            leftSeparator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            leftSeparator.heightAnchor.constraint(equalToConstant: 1.0),
            yearLabel.leadingAnchor.constraint(equalTo: leftSeparator.trailingAnchor, constant: 6.5)
        ])
    }
    
    func yearLabelConstraints() {
        NSLayoutConstraint.activate([
            yearLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            yearLabel.topAnchor.constraint(equalTo: self.topAnchor),
            yearLabel.heightAnchor.constraint(equalToConstant: 16.0),
            self.bottomAnchor.constraint(equalTo: yearLabel.bottomAnchor)
        ])
    }
    
    func rightSeparatorConstraints() {
        NSLayoutConstraint.activate([
            rightSeparator.centerYAnchor.constraint(equalTo: yearLabel.centerYAnchor),
            rightSeparator.leadingAnchor.constraint(equalTo: yearLabel.trailingAnchor, constant: 6.5),
            rightSeparator.heightAnchor.constraint(equalToConstant: 1.0),
            self.trailingAnchor.constraint(equalTo: rightSeparator.trailingAnchor)
        ])
    }
}
