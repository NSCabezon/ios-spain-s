//
//  ContactsView.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 30/12/2020.
//
import CoreFoundationLib

public final class ContactsView: UIView {
    private lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.image = Assets.image(named: "icnHintFavourite")
        NSLayoutConstraint.activate([
            imgView.heightAnchor.constraint(equalToConstant: 20),
            imgView.widthAnchor.constraint(equalToConstant: 20)
        ])
        return imgView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setSantanderTextFont(type: .regular, size: 10.0, color: .white)
        label.text = localized("generic_button_contactBook")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.backgroundColor = .darkTorquoise
        self.addSubview(self.imageView)
        self.addSubview(self.label)
        NSLayoutConstraint.activate([
            self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 6.0)
        ])

        NSLayoutConstraint.activate([
            self.label.topAnchor.constraint(equalTo: self.imageView.bottomAnchor),
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 6.0),
            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6.0)
        ])
    }
}
