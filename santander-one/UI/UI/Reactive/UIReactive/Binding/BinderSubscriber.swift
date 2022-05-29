import Foundation
import OpenCombine

/// Handles upstream published values by assigning them to a specific object
///
/// Use `bind(to:)` to decide which object property is going to receive upstream value to assign them
///
/// In the example below, we create a custome `UIView` then we add a `Value` `Binder` property to our `UIReactive`.
/// More over, we have an array publisher that emits values we gonna collect them using`collect(_:)` operator
/// finaly use the `bind(to:)` to assing the publisher output value to the bindable property  `view.bindable.value` we create before
/// in our custome view, this property should has the same type as publisher output.
///
///      class MyView: UIView {
///          var value = [Int]()
///      }
///
///      extension UIReactive where Base: MyView {
///         var value: Binder<Base, [Int]> {
///             return Binder(base) { view, value in
///                view.value = value
///             }
///         }
///      }
///
///      let view = MyView()
///      let publisher = [1,2,3,4].publisher
///
///      publisher
///         .collect()
///         .bind(to: view.bindable.value)
///         .store(in: &subscriptions)
///
///      print(view.value)
///
///      // Prints: [1,2,3,4]
///
/// - Parameter owner: Usualy an object that conform AnyObject like `UIView` does
/// - Parameter bind: A  closure that accepts owner and the input value
/// - Returns: returns a AnyCancelable object that allow you to cancel the subscription.
public final class Binder<Owner: AnyObject, Input>: Subscriber, Cancellable {
    public typealias Failure = Never
    private var subscription: Subscription?
    private var bind: (Owner, Input) -> Void
    private weak var owner: Owner?
    
    public init(_ owner: Owner, bind: @escaping (Owner, Input) -> Void) {
        self.owner = owner
        self.bind = bind
    }
    
    public func receive(subscription: Subscription) {
        self.subscription = subscription
        self.subscription?.request(.unlimited)
    }
    
    public func receive(_ input: Input) -> Subscribers.Demand {
        if let weakOwner = owner {
            bind(weakOwner, input)
        } else {
            self.subscription?.cancel()
        }
        return .none
    }
    
    public func receive(completion: Subscribers.Completion<Never>) {
        subscription = nil
    }

    public func cancel() {
        bind = { _, _ in }
        owner = nil
        subscription?.cancel()
    }
}

public extension OpenCombine.Publisher {
/// Operator that allow to bind not optional upstream ouput to a optional bindable Input
///
///     let values:[String] = ["Hello", "how is it going"]
///     let label = UILable()
///     let publisher = values.publisher
///
///     publisher
///       .bind(to: myLabel.bindable.text)
///       .store(in: &subscription)
///
    func bind<S>(to subscriber: S) -> AnyCancellable where S: Subscriber, S: Cancellable, S.Input == Self.Output?, S.Failure == Self.Failure {
        self.map(Optional.init).subscribe(subscriber)
        return AnyCancellable(subscriber)
    }

/// Operator that allow to bind upstream value to a bindable Input
    func bind<S>(to subscriber: S) -> AnyCancellable where S: Subscriber, S: Cancellable, S.Input == Self.Output, S.Failure == Self.Failure {
        subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
}
