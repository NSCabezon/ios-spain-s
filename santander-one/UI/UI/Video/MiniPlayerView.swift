import UIKit
import youtube_ios_player_helper
import CoreFoundationLib

public final class MiniPlayerView: XibView {
    @IBOutlet private weak var buttonPlay: UIButton!
    @IBOutlet private weak var buttonClose: UIButton!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var loadingView: UIView!
    @IBOutlet private weak var ytpPlayerView: YTPlayerView!
    @IBOutlet private weak var playerView: UIView!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    private static weak var lastMiniPlayerView: MiniPlayerView?
    private var isPlaying: Bool = false
    private var timer: Timer?
    private var maxTopPosition: CGFloat = UIScreen.main.bounds.height
    private let isFullScreenEnabled: Bool = false
    private let closingTime: Double = 3
    
    public static func play(_ videoId: String) {
        self.lastMiniPlayerView?.close()
        let playerView = MiniPlayerView()
        let window = UIApplication.shared.keyWindow
        window?.addSubview(playerView)
        playerView.fullFit()
        playerView.showLoading()
        playerView.play(videoId)
        self.lastMiniPlayerView = playerView
    }
    
    public static func bringToFront() {
        guard let window = UIApplication.shared.keyWindow,
            let view = lastMiniPlayerView else {
            return
        }
        window.bringSubviewToFront(view)
    }
    
    public static func close() {
        self.lastMiniPlayerView?.close()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let elements: [UIView] = [self.buttonClose, self.buttonPlay]
        for element in elements {
            if !element.isHidden, element.frame.contains(point) {
                return element
            }
        }
        if self.playerView.frame.contains(point) {
            self.showControls(true)
            return super.hitTest(point, with: event)
        }
        return nil
    }
}

// MARK: - YTPlayerViewDelegate

extension MiniPlayerView: YTPlayerViewDelegate {
    public func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.play()
    }
    
    public func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .buffering:
            self.hideLoading()
        case .ended:
            self.playerItemDidReachEnd()
        case .paused:
            self.isPlaying = false
            self.showControls(false)
        case .playing:
            self.isPlaying = true
            self.showControls(true)
        default:
            break
        }
    }
    
    public func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        self.close()
    }
    
    public func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
        return UIColor.black
    }
    
    public func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
        let loadingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        loadingView.backgroundColor = UIColor.black
        return loadingView
    }
}

// MARK: - Private

private extension MiniPlayerView {
    func showLoading() {
        self.loadingView.isHidden = false
        self.loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        self.loadingView.isHidden = true
        self.loadingIndicator.stopAnimating()
    }
    
    func play(_ videoId: String) {
        self.ytpPlayerView.delegate = self
        let controls: String = self.isFullScreenEnabled ? "2": "0"
        let playVarsDictionary: [String: String] = [
            "playsinline": "1",
            "controls": controls,
            "showinfo": "1",
            "autoplay": "0",
            "modestbranding": "1",
            "rel": "0"
        ]
        self.ytpPlayerView.load(withVideoId: videoId, playerVars: playVarsDictionary)
    }

    @IBAction func play() {
        if self.isPlaying {
            self.ytpPlayerView.pauseVideo()
        } else {
            self.ytpPlayerView.playVideo()
        }
    }
    
    @IBAction func close() {
        self.ytpPlayerView.stopVideo()
        self.removeFromSuperview()
    }
    
    @IBAction func dragView(_ gesture: UIPanGestureRecognizer) {
        let translatedPoint: CGPoint = gesture.translation(in: self)
        var newTopPosition: CGFloat = self.topConstraint.constant + translatedPoint.y
        if newTopPosition < 0 {
            newTopPosition = 0
        } else {
            if newTopPosition > self.maxTopPosition {
                newTopPosition = self.maxTopPosition
            }
        }
        self.topConstraint.constant = newTopPosition
        gesture.setTranslation(CGPoint.zero, in: gesture.view)
    }
    
    func playerItemDidReachEnd() {
        self.ytpPlayerView.pauseVideo()
        self.ytpPlayerView.seek(toSeconds: 0, allowSeekAhead: true)
        self.isPlaying = false
        self.showControls(false)
    }
    
    func setupView() {
        self.view?.backgroundColor = UIColor.clear
        self.setupSize()
        self.setupLoading()
        self.setupPlayer()
        self.setAccesibilityIdentifiers()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragView))
        self.playerView.addGestureRecognizer(panGesture)
    }
    
    func setupSize() {
        let screenSize: CGRect = UIScreen.main.bounds
        let window = UIApplication.shared.keyWindow
        let topPadding: CGFloat
        let bottomPadding: CGFloat
        if #available(iOS 11.0, *) {
            topPadding = window?.safeAreaInsets.top ?? 0
            bottomPadding = window?.safeAreaInsets.bottom ?? 0
        } else {
            topPadding = 0
            bottomPadding = 0
        }
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height - topPadding
        let playerWidth = screenWidth - 16
        let playerHeight = playerWidth * 245 / 400
        self.maxTopPosition = screenHeight - playerHeight - bottomPadding
        self.topConstraint.constant = screenHeight / 2 - playerHeight / 2
    }
    
    func setupLoading() {
        self.loadingView.backgroundColor = UIColor.black
        if #available(iOS 13.0, *) {
            self.loadingIndicator.style = .large
        } else {
            self.loadingIndicator.style = .whiteLarge
        }
        self.loadingIndicator.color = UIColor.white
        self.loadingIndicator.hidesWhenStopped = true
    }
    
    func setupPlayer() {
        self.buttonPlay.isHidden = true
        self.playerView.backgroundColor = UIColor.clear
        self.playerView.layer.masksToBounds = false
        self.playerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.playerView.layer.shadowOpacity = 0.7
        self.playerView.layer.shadowColor = UIColor.lightSanGray.cgColor
        self.playerView.layer.shadowRadius = 3
        self.loadingView.clipsToBounds = true
        self.loadingView.layer.cornerRadius = 6
        self.ytpPlayerView.clipsToBounds = true
        self.ytpPlayerView.layer.cornerRadius = 6
        self.buttonPlay.setImage(Assets.image(named: "icnPlayVideo"), for: .normal)
        self.buttonClose.setImage(Assets.image(named: "icnCloseVideo"), for: .normal)
    }
    
    func setAccesibilityIdentifiers() {
        self.buttonPlay.accessibilityIdentifier = AccessibilityVideo.btnPlay.rawValue
        self.buttonClose.accessibilityIdentifier = AccessibilityVideo.btnClose.rawValue
        self.ytpPlayerView.accessibilityIdentifier = AccessibilityVideo.layout.rawValue
    }
    
    func showControls(_ isTimerEnabled: Bool) {
        self.timer?.invalidate()
        self.timer = nil
        self.buttonClose.isHidden = false
        self.buttonPlay.isHidden = self.isFullScreenEnabled ? true: false
        let imagePlay = self.isPlaying ? Assets.image(named: "icnPauseVideo"): Assets.image(named: "icnPlayVideo")
        self.buttonPlay.setImage(imagePlay, for: .normal)
        if isTimerEnabled {
            self.timer = Timer.scheduledTimer(withTimeInterval: self.closingTime, repeats: false, block: { [weak self] _ in
                self?.timer = nil
                self?.hideControls()
            })
        }
    }
    
    func hideControls() {
        self.buttonPlay.isHidden = true
        self.buttonClose.isHidden = true
    }
}
