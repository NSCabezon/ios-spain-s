import Fuzi
import CoreDomain

class OfferActionParser: Parser {
    
    var logTag: String {
        return String(describing: type(of: self))
    }
    
    func deserialize(_ parseable: OfferActionRepresentable) -> String? {
        return ""
    }
    
    func serialize(_ responseString: String) -> OfferActionRepresentable? {
        guard
            let document = try? XMLDocument(string: responseString),
            let root = document.root,
            let attr = root.attributes.first, attr.key == "type"
        else { return nil }
        switch attr.value {
        case "creativity":
            let topTitle = root.firstChild(tag: "top_title")?.stringValue ?? ""
            let title = root.firstChild(tag: "title")?.stringValue ?? ""
            let buttonUp = OfferButtonParser().serialize(root.firstChild(tag: "button_up")?.description ?? "")
            let button_left = OfferButtonParser().serialize(root.firstChild(tag: "button_left")?.description ?? "")
            let button_right = OfferButtonParser().serialize(root.firstChild(tag: "button_right")?.description ?? "")
            var outputCarousel = [BannerDTO]()
            if let carousel = root.firstChild(tag: "carousel") {
                let app = carousel.firstChild(tag: "creativity_images")?.attributes["app"] ?? ""
                if let creativity_images = carousel.firstChild(tag: "creativity_images") {
                    for banner in creativity_images.children(tag: "creativity_image") {
                        var height = ""
                        var width = ""
                        for (key, value) in banner.attributes {
                            if key == "height" {
                                height = value
                            }
                            if key == "width" {
                                width = value
                            }
                        }
                        let url = banner.stringValue.replace("\n", "").trimed
                        let newBanner = BannerDTO(app: app, height: Float(height) ?? 0, width: Float(width) ?? 0, url: url)
                        outputCarousel.append(newBanner)
                    }
                }
            }
            let action = CreativityAction(topTitle: topTitle, title: title, buttonUp: buttonUp, buttonLeft: button_left, buttonRight: button_right, carousel: outputCarousel)
            return action
        case "open_webview":
            var navigations: [OpenWebViewActionNavigations]?
            if let webViewNavigations = root.firstChild(tag: "navigations") {
                navigations = webViewNavigations.children.compactMap { parameter in
                    guard let url = parameter.firstChild(tag: "url")?.stringValue.trim(),
                          let operative = parameter.firstChild(tag: "operative")?.stringValue
                    else { return nil }
                    let id = parameter.firstChild(tag: "id")?.stringValue
                    return OpenWebViewActionNavigations(url: url, operative: operative, id: id)
                }
            }
            let topTitle = root.firstChild(tag: "top_title")?.stringValue ?? ""
            let reload_session_on_close: Bool = Bool(root.firstChild(tag: "reload_session_on_close")?.stringValue.trimed ?? "false") ?? false
            let open_url = root.firstChild(tag: "open_url")?.stringValue.trim() ?? ""
            let close_url = root.firstChild(tag: "close_url")?.stringValue.trim() ?? ""
            let pdf_name = root.firstChild(tag: "pdf_name")?.stringValue ?? ""
            let method = root.firstChild(tag: "method")?.stringValue ?? ""
            let webViewTimer = root.firstChild(tag: "timerLoadingTips")?.stringValue ?? "0"
            var httpMethodType: HTTPMethodType
            switch method {
            case "GET":
                httpMethodType = .get
            case "POST":
                httpMethodType = .post
            default:
                httpMethodType = .post
            }
            var parametersType: WebviewActionParametersType?
            if let parametersTypeString = root.firstChild(tag: "parametersType")?.stringValue {
                switch parametersTypeString {
                case "query":
                    parametersType = .query
                case "body":
                    parametersType = .body
                default: break
                }
            }
            var outputParams: [OfferWebViewParameter] = []
            if let parameters = root.firstChild(tag: "parameters") {
                outputParams = parameters.children.compactMap { parameter in
                    guard let key = parameter.attr("name") else { return nil }
                    return OfferWebViewParameter(key: key, value: parameter.stringValue)
                }
            }
            let webviewEngineVersion = OpenWebviewActionEngine(rawValue: root.firstChild(tag: "ios_webview_engine_version")?.stringValue ?? "") ?? .wkWebView
            let isIgnorePdfEnabled: Bool = Bool(root.firstChild(tag: "except_download_pdf")?.stringValue.trimed ?? "false") ?? false
            let isFullScreenEnabled: Bool = Bool(root.firstChild(tag: "full_screen_enabled")?.stringValue.trimed ?? "false") ?? false
            var outputHeaders: [OpenWebViewHeader]?
            if let headers = root.firstChild(tag: "headers") {
                outputHeaders = headers.children.compactMap { header in
                    guard let key = header.attr("name") else { return nil }
                    return OpenWebViewHeader(key: key, value: header.stringValue)
                }
            }
            let action = OpenWebviewAction(topTitle: topTitle,
                                           reloadSessionOnClose: reload_session_on_close,
                                           openUrl: open_url,
                                           closeUrl: close_url,
                                           pdfName: pdf_name,
                                           method: httpMethodType,
                                           parameters: outputParams,
                                           navigations: navigations,
                                           webviewEngineVersion: webviewEngineVersion,
                                           isIgnorePdfEnabled: isIgnorePdfEnabled,
                                           timerLoadingTips: webViewTimer,
                                           parametersType: parametersType,
                                           isFullScreenEnabled: isFullScreenEnabled,
                                           headers: outputHeaders)
            return action
        case "external_url":
            let url = root.firstChild(tag: "action_value")?.stringValue ?? ""
            return ExternalUrlAction(actionValue: url)
        case "fullscreen-banner":
            var bannerFullScreenBanner: BannerDTO?
            guard let banner = root.firstChild(tag: "banner") else { return nil }
            var app = ""
            var height = ""
            var width = ""
            for (key, value) in banner.attributes {
                if key == "app" {
                    app = value
                }
                if key == "height" {
                    height = value
                }
                if key == "width" {
                    width = value
                }
            }
            
            let url = banner.stringValue.replace("\n", "").trimed
            bannerFullScreenBanner = BannerDTO(app: app, height: Float(height) ?? 0, width: Float(width) ?? 0, url: url)
            var action: OfferActionRepresentable?
            if let actionImage = root.firstChild(tag: "action"), let offerAction = OfferActionParser().serialize(actionImage.description) {
                action = offerAction
            }
            guard let time = root.firstChild(tag: "close_time")?.stringValue,
                let closeTime = Int(time) else {
                    return nil
            }
            let transparentClosure = Bool(root.firstChild(tag: "transparent_closure")?.stringValue.trimed ?? "false") ?? false
            guard let bannerOffer = bannerFullScreenBanner else { return nil }
            return FullScreenBannerAction(action: action, time: closeTime, banner: bannerOffer, transparentClosure: transparentClosure)
            
        case "detail":
            let topTitle = root.firstChild(tag: "top_title")?.stringValue
            let description = root.firstChild(tag: "description")?.stringValue
            var bannerPage: BannerDTO?
            if let banners = root.firstChild(tag: "detail_banners"), let banner = banners.firstChild(tag: "detail_banner") {
                var app = ""
                var height = ""
                var width = ""
                for (key, value) in banner.attributes {
                    if key == "app" {
                        app = value
                    }
                    if key == "height" {
                        height = value
                    }
                    if key == "width" {
                        width = value
                    }
                }
                let url = banner.stringValue.replace("\n", "").trimed
                bannerPage = BannerDTO(app: app, height: Float(height) ?? 0, width: Float(width) ?? 0, url: url)
            }
            var button1: OfferButton?
            var button2: OfferButton?
            if let button = root.firstChild(tag: "button_1"), let offerButton = OfferButtonParser().serialize(button.description) {
                button1 = offerButton
            }
            if let button = root.firstChild(tag: "button_2"), let offerButton = OfferButtonParser().serialize(button.description) {
                button2 = offerButton
            }
            return DetailAction(topTitle: topTitle, description: description, detailBanner: bannerPage, button1: button1, button2: button2)
        case "image_list_fullscreen":
            let topTitle = root.firstChild(tag: "top_title")?.stringValue ?? ""
            var outputList = [ListPageDTO]()
            if let list = root.firstChild(tag: "list") {
                for page in list.children {
                    var action: OfferActionRepresentable?
                    if let actionImage = page.firstChild(tag: "action"), let offerAction = OfferActionParser().serialize(actionImage.description) {
                        action = offerAction
                    }
                    outputList.append(ListPageDTO(imageFullscreen: page.firstChild(tag: "image_fullscreen")?.stringValue.trim() ?? "", action: action))
                }
            }
            return ImageListAction(topTitle: topTitle, list: outputList)
        case "video":
            let url = root.firstChild(tag: "action_value")?.stringValue ?? ""
            return VideoAction(actionValue: url)
        case "navigate_screen":
            let url = root.firstChild(tag: "action_value")?.stringValue ?? ""
            let id = root.firstChild(tag: "id")?.stringValue ?? ""
            return NavigateScreenAction(actionValue: url, id: id)
        case "offer_link":
            let url = root.firstChild(tag: "action_value")?.stringValue ?? ""
            return OfferLinkAction(actionValue: url)
        case "phone_call":
            let url = root.firstChild(tag: "action_value")?.stringValue ?? ""
            return PhoneCallAction(actionValue: url)
        case "tutorial":
            let topTitle = root.firstChild(tag: "top_title")?.stringValue
            var pages: [TutorialPage] = []
            if let list = root.firstChild(tag: "list") {
                for page in list.children {
                    let title = page.firstChild(tag: "title")?.stringValue
                    let description = page.firstChild(tag: "desc")?.stringValue
                    var bannerPage: BannerDTO?
                    var actionButton: OfferButton?
                    if let banners = page.firstChild(tag: "banners"), let banner = banners.firstChild(tag: "banner") {
                        var app = ""
                        var height = ""
                        var width = ""
                        for (key, value) in banner.attributes {
                            if key == "app" {
                                app = value
                            }
                            if key == "height" {
                                height = value
                            }
                            if key == "width" {
                                width = value
                            }
                        }
                        let url = banner.stringValue.replace("\n", "").trimed
                        bannerPage = BannerDTO(app: app, height: Float(height) ?? 0, width: Float(width) ?? 0, url: url)
                    }
                    if let button = page.firstChild(tag: "button")?.description {
                        actionButton = OfferButtonParser().serialize(button)
                    }
                    let tutorialPage = TutorialPage(title: title, description: description, banner: bannerPage, actionButton: actionButton)
                    pages.append(tutorialPage)
                }
            }
            return TutorialAction(topTitle: topTitle, tutorialPages: pages)
        case "open_app":
            let appUrlScheme = root.firstChild(tag: "app_url_scheme")?.stringValue
            let iosStoreAppId = root.firstChild(tag: "ios_store_app_id")?.stringValue
            let fallbackStore = root.firstChild(tag: "fallback_store")?.stringValue == "true"
            let enableSso = root.firstChild(tag: "enable_sso")?.stringValue == "true"
            return OpenAppAction(appUrlScheme: appUrlScheme, iosStoreAppId: iosStoreAppId, fallbackStore: fallbackStore, enableSso: enableSso)
        //Empty options. Not used. Mandatory due an empty case go to default option
        case "bubble_banner":
            guard let time = root.firstChild(tag: "close_time")?.stringValue,
                let closeTime = Int(time) else {
                    return nil
            }
            var action: OfferActionRepresentable?
            if let actionImage = root.firstChild(tag: "action"), let offerAction = OfferActionParser().serialize(actionImage.description) {
                action = offerAction
            }
            guard let bannerValues = root.firstChild(tag: "banner") else { return nil }
            let app = bannerValues.attributes["app"] ?? ""
            let height = bannerValues.attributes["height"] ?? ""
            let width = bannerValues.attributes["width"] ?? ""
            let url = bannerValues.stringValue.trimed
            let banner = BannerDTO(app: app, height: Float(height) ?? 0, width: Float(width) ?? 0, url: url)
            return BubbleBannerAction(closeTime: closeTime, banner: banner, action: action)
        case "small-bottom-banner":
            guard let time = root.firstChild(tag: "close_time")?.stringValue,
                let closeTime = Int(time) else {
                    return nil
            }
            guard let bannerValues = root.firstChild(tag: "banner") else { return nil }
            var app = ""
            var height = ""
            var width = ""
            for (key, value) in bannerValues.attributes {
                if key == "app" {
                    app = value
                }
                if key == "height" {
                    height = value
                }
                if key == "width" {
                    width = value
                }
            }
            
            let url = bannerValues.stringValue.replace("\n", "").trimed
            let banner = BannerDTO(app: app, height: Float(height) ?? 0, width: Float(width) ?? 0, url: url)
            
            var action: OfferActionRepresentable?
            if  let actionValue = root.firstChild(tag: "action"),
                let offerAction = OfferActionParser().serialize(actionValue.description) {
                action = offerAction
            }
            
            return SmallBottomBannerAction(
                closeTime: closeTime,
                banner: banner,
                action: action
            )
        case "":
            return nil
        default:
            let value = root.firstChild(tag: "action_value")?.stringValue ?? ""
            return NotSupportedAction(actionValue: value)
        }
    }
    
}
