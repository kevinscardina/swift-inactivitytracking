import UIKit

class ViewController: UIViewController {
    private let timeOut: Double = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidTimeout(notification:)),
                                               name: .applicationInactivityTimeOut,
                                               object: nil)
        drawButton()
    }
    
    @objc private func applicationDidTimeout(notification: Notification) {
        showAlert(title: "Time Out", message: "Your time has run out!") { (action) in
            self.stopTracking()
            // here you could log the user out
        }
    }
    
    @IBAction private func startTracking() {
        (UIApplication.shared as? InactivityTrackingApplication)?.startTracking(timeOut: timeOut)
        drawButton(state: .two)
    }
    
    @IBAction private func stopTracking() {
        (UIApplication.shared as? InactivityTrackingApplication)?.stopTracking()
        drawButton(state: .one)
    }
    
    enum ButtonStates: String {
        case one = "🏃‍♂️ Start Inactivity Tracking"
        case two = "🛑 Stop Inactivity Tracking"
    }
    
    private func drawButton(state: ButtonStates = .one) {
        (view.subviews.filter { $0 is UIButton }).first?.removeFromSuperview()
        let button = UIButton()
        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitle(state.rawValue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: state == .one ? #selector(startTracking) : #selector(stopTracking), for: .touchUpInside)
        view.addSubview(button)
        button.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    private func showAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIDevice.current.userInterfaceIdiom == .pad
                                        ? .alert
                                        : .actionSheet)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: handler))
        present(alert, animated: true, completion: nil)
    }
}

