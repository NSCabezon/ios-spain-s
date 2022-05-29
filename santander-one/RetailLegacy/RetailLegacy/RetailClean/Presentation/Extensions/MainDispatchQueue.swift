import Foundation

func dispatchOnMainQueue(afterSeconds seconds: TimeInterval, execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(seconds * 1000)), execute: execute)
}
