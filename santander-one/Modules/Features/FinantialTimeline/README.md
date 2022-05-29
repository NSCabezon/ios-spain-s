# FinantialTimeline iOS

[![Platform](https://img.shields.io/badge/platform-iOS-blue)](https://github.com/globile-software/IB-FinantialTimeline-iOS)
[![Language](https://img.shields.io/badge/language-swift-orange)](https://github.com/globile-software/IB-FinantialTimeline-iOS)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

FinantialTimeline is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
source 'git@github.com:globile-software/IB-FinantialTimeline-iOS.git'
source 'git@github.com:globile-software/Arch-ComponentPods-iOS.git' # Since the TimeLine module has some dependencies of Arch-ComponentPods-iOS

pod 'FinantialTimeline', :git => 'git@github.com:globile-software/IB-FinantialTimeline-iOS.git', :branch => 'master'
```

## Usage

### Configuration

First of all, you have to configure the Timeline module. There is an entity called `Configuration` with all public configuration that you have to configure.

#### Native mode

```swift
Configuration.native(
    host: URL(string: "https://...")!,
    configurationURL: URL(string: "https://...")!,
    currencySymbols: ["EUR": "€", "USD", "$"]],
    authorization: .token("xxxxxxxx"),
    timeLineDelegate: delegate,
    actions: [remindMeAction, shareAction],
    language: String
)
```

* `host`: it is the url of the TimeLine WS (without any path).
* `configurationURL`: it is the whole url of the TimeLine configuration file.
* `currencySymbols`: it is a dictionary with all currencies codes - symbols that you want to show in your TimeLine integration.
* `authorization`: it is the method that you want to use to authenticate with your WS.
* `TimeLineDelegate`: it is the controller that implements the TimeLineDelegate with its methods expecting the tap on any of the posible CTAs 
* `actions`: it is an array of  `CTAAction` objects.
* `language`: it is an String with the desired language code

#### Hybrid mode

```swift
Configuration.hybrid(
    url: URL(string: "https://...")!,
    authorization: .token("xxxxxxxx",
    language: String)
)
```
* `url`: it is the url of the TimeLine web app. 
* `authorization`: it is the method that you want to use to authenticate with your TimeLine web app.
* `language`: it is an String with the desired language code

To finish the setup process, call the `setup()` method before calling anything else of TimeLine:

```swift
let configuration = Configuration.native(
    host: URL(string: "https://...")!,
    configurationURL: URL(string: "https://...")!,
    currencySymbols: ["EUR": "€", "USD", "$"]],
    authorization: .token("xxxxxxxx")
)
TimeLine.setup(configuration: configuration)
```

### Launch

Since TimeLine have it owns interface, you just have to call to the following method to get an instance of a `TimeLineViewController` and show it wathever you want:

```swift
let timeLineViewController = TimeLine.load()
show(timeLineViewController, sender: nil)
```

### Show  Widget
Use the next method to load de widget's view.
* days: The number of days from today to search for elements.
* elements: Maximum elements to show

```swift
TimeLine.loadWidget(days: Int, elements: Int)
```

## Advanced

### TimeLine version

There is a way to get the current TimeLine module version by calling

```swift
TimeLine.version() // 1.0.0
```

## TimeLineDelegate

### Display number masking

You could implment a masking for the delicate infomation as the count or card numbers in the detail.  for this the app should implement the  `TimeLineDelegate`
```swift
extension YourController: TimeLineDelegate {
    func mask(displayNumber: String, completion: @escaping (String) -> Void) {
           completion("this is your masked object")
    }
}
```

### CTAs

The event detail could implement CTAs, for this the app should implement the  `TimeLineDelegate` and provide an array of CTAs implemented.

```swift
extension YourController: TimeLineDelegate {
    func onTimeLineCTATap(from viewController: UIViewController, with action: CTAAction) {
        switch action.action {
        case .remindMe:
           // Perform your action
        default:
            break
        }
    }
}
```

### Storage Reset

With this method, any stored data will be deleted or seted as their default value

```swift
TimeLine.resetStorage()
```

The `CTAAction` is the object the app should provide so the Timeline module knows wich CTAs are alredy implementd

```swift
let actions: [CTAAction] = [.init(action: .remindMe, identifier: "001"),
                            .init(action: .share, identifier: "002", handleInTimeline: true)]
```

### RestClient

By default, all web requests are performed and handled by the TimeLine module. But, there is a way to change it by creating a class that conforms the `RestClient` protocol and passing it as parameter in an advanced configuration method. It could be useful if you want to create an offline mode or you have any extra security or behaviour not included in the standard one (i.e. any extra header or param needed by your own TimeLine WS integration).

```swift
class HostAppOwnRestClient: RestClient {

    func request(host: String, path: String, method: RestClientHTTPMethod, headers: [String : String], params: RestClientParams, completion: @escaping (Result<Data, Error>) -> Void) {
        // Perform here the request or return the data that you consider 
    }
}
```

Then, setup the module adding this `RestClient` as parameter:

```swift
let restClient = HostAppOwnRestClient()
let configuration = TimeLinePublicConfiguration(
    host: URL(string: "https://...")!,
    configurationURL: URL(string: "https://...")!,
    currencySymbols: ["EUR": "€", "USD", "$"]],
    authorization: .token("xxxxxxxx")
)
TimeLine.setup(configuration: configuration, restClient: restClient)
```

## License

TBD
