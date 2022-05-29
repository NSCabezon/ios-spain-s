import UIKit

public final class VideoTooltipView: XibView {
    @IBOutlet private weak var videoImageview: UIImageView!
    @IBOutlet private weak var videoButton: UIButton!
    private var action: (() -> Void)?
    private var imageName: String?

    public convenience init(imageName: String, action: (() -> Void)?) {
        self.init(frame: CGRect.zero)
        self.action = action
        self.imageName = imageName
        setupView()
    }
}

private extension VideoTooltipView {
    func setupView() {
        if let imageName = self.imageName {
            self.videoImageview.image = Assets.image(named: imageName)
        } else {
            self.videoImageview.image = nil
        }
        self.videoButton.setImage(Assets.image(named: "icnPlay"), for: UIControl.State.normal)
    }
    
    @IBAction func didTouchVideo() {
        self.action?()
    }
}
