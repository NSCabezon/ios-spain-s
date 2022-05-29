//
//  TagsCollectionViewCell.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 11/02/2020.
//

import UIKit

public class TagCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier: String = "tagCellIdentifier"
    static let leftPading: CGFloat = 12.0
    static let rightPading: CGFloat = 22.0
    static let topBottomPadding: CGFloat = 14
    
    var tagView: TagView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        tagView = TagView()
        self.contentView.addSubview(tagView)
        tagView.translatesAutoresizingMaskIntoConstraints = false
        tagView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        tagView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        tagView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        tagView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
