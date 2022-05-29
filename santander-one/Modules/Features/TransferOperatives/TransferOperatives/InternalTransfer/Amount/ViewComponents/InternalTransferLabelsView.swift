//
//  InternalTransferLabelsView.swift
//  TransferOperatives
//
//  Created by Marcos Álvarez Mesa on 9/3/22.
//

import UIKit
import UIOneComponents
import CoreFoundationLib

final class InternalTransferLabelsView: UIView {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let title: String
    private let descriptionStr: String
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()

    init(title: String, description: String) {
        self.title = title
        self.descriptionStr = description
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension InternalTransferLabelsView {

    func configureView() {
        addSubviews()
        defineConstraints()
    }

    func addSubviews() {
        titleLabel.font = .typography(fontName: .oneB300Regular)
        titleLabel.textColor = .oneLisboaGray
        titleLabel.text = title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .typography(fontName: .oneB400Bold)
        descriptionLabel.textColor = .oneLisboaGray
        descriptionLabel.text = descriptionStr
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        addSubview(stackView)
    }

    func defineConstraints() {
        stackView.fullFit(leftMargin: 16, rightMargin: 16)
    }
}

