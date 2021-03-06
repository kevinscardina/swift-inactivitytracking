import UIKit
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

extension Notification.Name {
    /// Notification posted by InactivityTrackingApplication when inactivity has timed out
    static let applicationInactivityTimeOut = Notification.Name("com.davita.mcoe.dcc.applicationInactivityTimeOut")
}

/// Override `int main(int argc, char** argv)` the swift way ¯\_(ツ)_/¯
UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    NSStringFromClass(InactivityTrackingApplication.self),
    NSStringFromClass(AppDelegate.self)
)
