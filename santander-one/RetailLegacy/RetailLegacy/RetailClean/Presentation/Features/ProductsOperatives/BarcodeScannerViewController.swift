import UI
import UIKit
import AVFoundation
import CoreFoundationLib

protocol BarcodeScannerPresenterProtocol: Presenter {
    func showError()
    func barcodeDetected(code: String?)
    func close()
    func goToManualMode()
    func cameraIsReady()
}

extension BarcodeScannerViewController: LandscapeRightRotatable, ForcedRotatable {
    
    func forcedOrientationForPresentation() -> UIInterfaceOrientation {
        return .landscapeRight
    }
    
    func forcedOrientationForDismission() -> UIInterfaceOrientation? {
        return .portrait
    }
}

class BarcodeScannerViewController: BaseViewController<BarcodeScannerPresenterProtocol>, AVCaptureMetadataOutputObjectsDelegate {
    private var defaultOrientation: UIInterfaceOrientationMask { UIInterfaceOrientationMask.portrait.union(.landscape) }
    private var cameraDetected: Bool? = false
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var manualModeButton: RedButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var orientationHandler: OrientationHandler? {
        return UIApplication.shared.delegate as? OrientationHandler
    }
    
    override class var storyboardName: String {
        return "BillAndTaxesOperative"
    }
    
    func changeScannerDetection(pauseDetection: Bool) {
        cameraDetected = pauseDetection
    }
    
    // MARK: - styles func
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func setSubtitle(_ description: LocalizedStylableText) {
        subtitleLabel.set(localizedStylableText: description)
    }
    
    func setManualModeButton(_ text: LocalizedStylableText) {
        manualModeButton.set(localizedStylableText: text, state: .normal)
    }
    
    override func prepareView() {
        super.prepareView()
        
        cameraView.backgroundColor = .uiBlack
        closeButton.setImage(Assets.image(named: "icnCloseRed"), for: .normal)
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 17)))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 13)))
    }
    
    func prepareCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(captureMetadataOutput) {
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [.qr, .pdf417, .code128]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = cameraView.layer.bounds
        if previewLayer.connection?.isVideoOrientationSupported ?? false {
            previewLayer.connection?.videoOrientation = .landscapeRight
        }
        cameraView.layer.addSublayer(previewLayer)
    }
    
    private func failed() {
        presenter.showError()
        captureSession = nil
    }
    
    func startCapturing() {
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    func stopCapturing() {
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        orientationHandler?.applyOrientation(defaultOrientation)
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        orientationHandler?.restoreOrientation()
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {        
        //captureSession.stopRunning()
        if cameraDetected == false, let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue?.trimed else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            cameraDetected = true
            presenter.barcodeDetected(code: stringValue)
        }
    }
    
    @IBAction func manualPressed(_ sender: Any) {
        presenter.goToManualMode()
    }
    
    @IBAction func closePressed(_ sender: Any) {
        presenter.close()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
