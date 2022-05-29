//
//  EmitterHeaderTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/19/20.
//

import UIKit

protocol EmitterHeaderTableViewCellDelegate: AnyObject {
    func didSelectEmitterHeaderCell(_ cell: EmitterHeaderTableViewCell, viewModel: EmitterViewModel)
}

class EmitterHeaderTableViewCell: UITableViewCell {
    static let identifier = "EmitterHeaderTableViewCell"
    @IBOutlet weak var viewContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewContainer: HeaderContainerView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    private var viewModel: EmitterViewModel?
    weak var delegate: EmitterHeaderTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setAppearance()
        self.iconImageView?.image = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setAppearance()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setViewModel(_ viewModel: EmitterViewModel) {
        self.viewModel = viewModel
        self.nameLabel.text = viewModel.name
        self.codeLabel.text = viewModel.code
        self.setAppearance()
    }
    
    @IBAction func didSelectExpandOrCollapse(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        viewModel.toggle()
        self.delegate?.didSelectEmitterHeaderCell(self, viewModel: viewModel)
    }
}

private extension EmitterHeaderTableViewCell {
     private func setAppearance() {
        self.setIcon()
        if let viewModel = self.viewModel, viewModel.isExpanded {
            self.setExpandedAppearance()
        } else {
            self.setCollapsedAppearance()
        }
    }
    
    func setIcon() {
        self.iconImageView.image = nil
        self.iconImageView.clipsToBounds = true
        self.iconImageView.contentMode = .scaleAspectFit
        guard let viewModel = self.viewModel,
              let iconUrl = viewModel.iconUrl else {
              self.iconImageView.image = nil
            return
        }
        self.iconImageView.loadImage(urlString: iconUrl)
    }
    
    func setExpandedAppearance() {
        self.viewContainerBottomConstraint.constant = 0
        self.viewContainer.drawCornerExceptBottom()
        self.viewContainer.backgroundColor = .skyGray
    }
    
    func setCollapsedAppearance() {
        self.viewContainerBottomConstraint.constant = 3
        self.viewContainer.drawAllCornersWithShadow()
        self.viewContainer.backgroundColor = .white
    }
}
