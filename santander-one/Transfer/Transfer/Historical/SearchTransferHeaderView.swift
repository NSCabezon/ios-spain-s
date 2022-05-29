//
//  SearchTransferHeaderView.swift
//  Transfer
//
//  Created by alvola on 21/05/2020.
//

import UI
import CoreFoundationLib

final class SearchTransferHeaderView: UIView {
    
    private lazy var separationLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mediumSkyGray
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.santander(size: 18.0)
        label.textColor = .lisboaGray
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func searchText(_ text: String, results: Int) {
        let key = results == 1 ? "globalSearch_text_result_one" : "globalSearch_text_result_other"
        label.attributedText = nil
        label.set(localizedStylableText: localized(key, [StringPlaceholder(.number, String(results))]))
        
        if let attrib = label.attributedText {
            let muttableAttrib = NSMutableAttributedString(attributedString: attrib)
            let resultsAttributed = NSAttributedString(string: " \"\(text)\"",
                                                       attributes: [
                                                        NSAttributedString.Key.font: UIFont.santander(type: .bold, size: 18.0),
                                                        NSAttributedString.Key.foregroundColor: UIColor.lisboaGray
                                                       ])
            muttableAttrib.append(resultsAttributed)
            label.attributedText = muttableAttrib
        }
        label.accessibilityIdentifier = "resultTextField"
    }
}

private extension SearchTransferHeaderView {
    func commonInit() {
        self.backgroundColor = .white
        NSLayoutConstraint.activate(separationLineConstraints() + labelConstraints())
    }
    
    func separationLineConstraints() -> [NSLayoutConstraint] {
        return [separationLine.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: separationLine.trailingAnchor),
                self.bottomAnchor.constraint(equalTo: separationLine.bottomAnchor),
                separationLine.heightAnchor.constraint(equalToConstant: 1.0)]
    }
    
    func labelConstraints() -> [NSLayoutConstraint] {
        return [label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0),
                self.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16.0),
                self.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8.0),
                label.heightAnchor.constraint(equalToConstant: 23.0)]
    }
}
