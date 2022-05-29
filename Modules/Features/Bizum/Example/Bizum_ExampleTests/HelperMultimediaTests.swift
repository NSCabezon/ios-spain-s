import XCTest
import QuickSetup
import QuickSetupES
import UnitTestCommons
import CoreFoundationLib
import SANLibraryV3
@testable import Bizum
@testable import SANLibraryV3

class HelperMultimediaTests: XCTestCase {
    private let dependenciesResolver =  DependenciesDefault()
    private var sut = HelperMultimedia()
    var quickSetup: QuickSetupES.QuickSetupForSpainLibrary {
        QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.environmentPre, user: .demo)
    }

    override func setUpWithError() throws {
        self.dependenciesResolver.register(for: BSANManagersProvider.self, with: { _ in
            return self.quickSetup.managersProvider
        })
        quickSetup.setEnviroment(BSANEnvironments.enviromentPreWas9)
        quickSetup.doLogin(withUser: .demo)
    }

    func testDecodeImageShouldBase64InBothImagesSame() throws {
        let initialImage = getImage()
        let imageData = initialImage.jpegData(compressionQuality: 1) ?? Data()
        let base64Image: String = imageData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        let imageDataGenerate = sut.decodeImage(text: base64Image)!
        let imageGenerate = UIImage(data: imageDataGenerate) ?? UIImage()
        assert(self.compareImages(initialImage, with: imageGenerate), "The image are equals")
    }

    func testDecodeStringWithEmojisShouldSuccess() {
        let bizumText = "This is a bizum transfer 🟢"
        let base64EncodedString = sut.encodeDataStringWithEmoji(bizumText)
        let textResult = sut.decodeText(base64EncodedString)
        XCTAssertEqual(bizumText, textResult)
    }
}

private extension HelperMultimediaTests {
    func getImage() -> UIImage {
        let bundle = Bundle(for: type(of: self))
        let testImage = UIImage(named: "BizumImage", in: bundle, compatibleWith: nil)
        return testImage ?? UIImage()
    }

    func compareImages(_ image: UIImage, with image2: UIImage) -> Bool {
        let data1 = image.pngData()
        let base64Image1: String? = data1?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        let data2 = image.pngData()
        let base64Image2: String? = data2?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        return base64Image1 == base64Image2
    }
}
