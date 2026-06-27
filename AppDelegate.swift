import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var floatButtonWindow: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.backgroundColor = .clear
        window?.makeKeyAndVisible()

        setupFloatButton()
        return true
    }

    func setupFloatButton() {
        let screen = UIScreen.main.bounds
        floatButtonWindow = UIWindow(frame: CGRect(x: screen.width - 54, y: 300, width: 44, height: 44))
        floatButtonWindow?.windowLevel = UIWindow.Level.alert + 100
        floatButtonWindow?.backgroundColor = .clear
        floatButtonWindow?.rootViewController = FloatButtonVC()
        floatButtonWindow?.isHidden = false
        floatButtonWindow?.makeKeyAndVisible()
    }
}
