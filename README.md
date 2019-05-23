# Inactivity Logout Example

An example of using `main.swift` to add inactivity tracking and a time out to a project.  In the example I use a `UIViewController` subclass to handle the Notification Center Notification post, but it could also be handled in `AppDelegate` or even inside a singleton session manager class.

## Main.swift

By placing the `main.swift` file (name matters) in a swift project, it will allow a top level function call:

```swift
UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    NSStringFromClass(InactivityTrackingApplication.self),
    NSStringFromClass(AppDelegate.self)
)
```

This will set our `InactivityTrackingApplication` to the projects `UIApplication`.

## InactivityTrackingApplication

A subclass of UIApplication placed in the `main.swift` file and set to be the `UIApplication` to use for the project.

```swift
/// An UIApplication sub-class for monitoring user interaction, if no user interaction has happened
/// since the "time out" then a NotificationCenter Notification (com.davita.mcoe.dcc.applicationInactivityTimeOut)
/// is posted to the default NotificationCenter.
class InactivityTrackingApplication: UIApplication {
    /// set to the amount of time to time out in, defaults to 2 minutes
    var timeOut: Double = 2 * 60
    /// is true when user activity is being tracked.
    private(set) var isTracking: Bool = false
    /// set to true if you want to stop the tracking when the time out fires
    var stopTrackingOnTimeOut: Bool = false

    private var workItem: DispatchWorkItem?

    private func restartTracking() {
        if isTracking {
            workItem?.cancel()
            workItem = DispatchWorkItem {
                NotificationCenter.default.post(name: .applicationInactivityTimeOut,
                    object: nil
                )
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + self.timeOut, execute: workItem!)
            if stopTrackingOnTimeOut { stopTracking() }
        }
    }

    /// Starts tracking inactivity
    /// - parameters:
    ///     - timeOut: lenth of time the application can be inactive before timing out and posting the Notification
    func startTracking(timeOut: Double? = nil) {
        if let timeOut = timeOut { self.timeOut = timeOut }
        isTracking = true
        restartTracking()
    }

    /// Stops tracking the inactivity
    func stopTracking() {
        workItem?.cancel()
        isTracking = false
    }

    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)

        guard isTracking else { return }

        if let touches = event.allTouches {
            for touch in touches where touch.phase == UITouch.Phase.began {
                restartTracking()
            }
        }
    }
}
```

## Notification 

`InactivityTrackingApplication` will post a  `applicationInactivityTimeOut`  notification when:

- tracking is started
- no user ineraction with the application after the set `timeOut`

```swift
extension Notification.Name {
    /// Notification posted by InactivityTrackingApplication when inactivity has timed out
    static let applicationInactivityTimeOut = Notification.Name("com.davita.mcoe.dcc.applicationInactivityTimeOut")
}
```

## Using `InactivityTrackingApplication`

To use `InactivityTrackingApplication` have something register for the `applicationInactivityTimeOut` notification:

```swift
NotificationCenter.default.addObserver(self,
                                       selector: #selector(applicationDidTimeout(notification:)),
                                       name: .applicationInactivityTimeOut,
                                       object: nil)
//...
@objc private func applicationDidTimeout(notification: Notification) {
    // do what you do when the inactivity has reached time out, maybe logout user...
}
```

To start tracking user inactivity call the applications `startTracking` function:

```swift
(UIApplication.shared as? InactivityTrackingApplication)?.startTracking(timeOut: 5)
```

To stop tracking user inactivity call the applications `stopTracking` function:

```swift
(UIApplication.shared as? InactivityTrackingApplication)?.stopTracking()
```

