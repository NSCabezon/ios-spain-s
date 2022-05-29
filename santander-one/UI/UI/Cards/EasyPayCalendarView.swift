//
//  EasyPayCalendarView.swift
//  Cards
//
//  Created by alvola on 11/12/2020.
//

public final class EasyPayCalendarView: UIView {
    private lazy var paymentImageView: UIImageView = {
        let image = UIImageView(image: Assets.image(named: "icnBigCalendarGray"))
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        return image
    }()
    
    private lazy var feeDayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = .lisboaGray
        label.font = UIFont.santander(type: .bold, size: 12.0)
        paymentImageView.addSubview(label)
        return label
    }()
    
    private lazy var feeMonthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.baselineAdjustment = .alignCenters
        label.textColor = .lisboaGray
        label.font = UIFont.santander(type: .bold, size: 12.0)
        paymentImageView.addSubview(label)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public func setDay(_ day: String, month: String) {
        feeDayLabel.text = day
        feeMonthLabel.text = month.uppercased()
    }
    
    public func setImageColor(_ color: UIColor) {
        paymentImageView.tintColor = color
    }
}

private extension EasyPayCalendarView {
    func setup() {
        paymentImageViewConstraints()
        feeDateLabelsConstraints()
    }
    
    func paymentImageViewConstraints() {
        NSLayoutConstraint.activate([
            paymentImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            paymentImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            paymentImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            paymentImageView.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])
    }
    
    func feeDateLabelsConstraints() {
        NSLayoutConstraint.activate([
            feeDayLabel.centerXAnchor.constraint(equalTo: paymentImageView.centerXAnchor),
            feeDayLabel.bottomAnchor.constraint(equalTo: paymentImageView.centerYAnchor, constant: 4.0),
            feeDayLabel.heightAnchor.constraint(equalToConstant: 12.0),
            feeMonthLabel.centerXAnchor.constraint(equalTo: paymentImageView.centerXAnchor),
            feeMonthLabel.topAnchor.constraint(equalTo: paymentImageView.centerYAnchor, constant: 4.0),
            feeMonthLabel.heightAnchor.constraint(equalToConstant: 13.0)
        ])
    }
}
