//
//  BallsLoaderView.swift
//  GlobalPosition
//

import UI
final class BallsLoaderView: UIView {
    
    private let indexLabel = "[index]"
    
    private let title: String
    private let subTitle: String
    
    private lazy var loader: UIImageView = {
        var images = [UIImage?]()
        for index in 0...251 {
            let revision = "balls_\(indexLabel)".replace(indexLabel, String(format: "%03d", index))
            images.append(Assets.image(named: revision))
        }
        let animation = UIImageView()
        animation.animationImages = images.compactMap {$0}
        return animation
    }()
    
    init(title: String, subTitle: String) {
        self.title = title
        self.subTitle = subTitle
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        self.title = ""
        self.subTitle = ""
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setupLoader()
        setupTitles()
    }
    
    private func setupLoader() {
        addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false

        loader.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loader.topAnchor.constraint(equalTo: topAnchor, constant: 112.0).isActive = true
        loader.widthAnchor.constraint(equalToConstant: 90.0).isActive = true
        loader.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
    }
    
    private func setupTitles() {
        let titleLabel = UILabel(frame: .zero)
        addSubview(titleLabel)
        titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 22.0)
        titleLabel.textColor = UIColor.lisboaGray
        titleLabel.text = title
        titleLabel.textAlignment = .center

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: loader.bottomAnchor, constant: 20.0).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 27.0).isActive = true
        
        let subTitleLabel = UILabel(frame: .zero)
        addSubview(subTitleLabel)
        subTitleLabel.font = UIFont.santander(family: .text, type: .regular, size: 15.0)
        subTitleLabel.textColor = UIColor.lisboaGray
        subTitleLabel.text = subTitle
        subTitleLabel.textAlignment = .center

        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0).isActive = true
        subTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        subTitleLabel.heightAnchor.constraint(equalToConstant: 18.0).isActive = true
    }
    
    func startAnimating() {
        loader.startAnimating()
    }
    
    func stopAnimating() {
        loader.stopAnimating()
    }
}
