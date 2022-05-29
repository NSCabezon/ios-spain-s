//
//  BizumSummaryMultimediaView.swift
//  Bizum
//
//  Created by Jose C. Yebes on 21/10/2020.
//

import UI

final class BizumSummaryMultimediaView: XibView {
    @IBOutlet weak private var photoImageView: UIImageView!
    @IBOutlet weak private var label: UILabel!
    @IBOutlet weak private var pointLine: PointLine!
    @IBOutlet weak private var widthImageConstraint: NSLayoutConstraint!
    @IBOutlet weak private var heightImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setup(_ viewModel: BizumSummaryMultimediaItemViewModel) {
        self.photoImageView.drawBorder(cornerRadius: 5.0, color: .clear, width: 0.0)
        self.widthImageConstraint.constant = viewModel.imageSize.width
        self.heightImageConstraint.constant = viewModel.imageSize.height
        self.photoImageView.image = viewModel.image
        self.label.text = viewModel.text
        self.imageTopConstraint.constant = viewModel.topMargin
    }
    
    func showSeparator() {
        self.pointLine.isHidden = false
    }
}
private extension BizumSummaryMultimediaView {
    func setupView() {
        self.label.setSantanderTextFont(type: .italic, size: 14.0, color: .lisboaGray)
        self.pointLine.isHidden = true
    }
}
