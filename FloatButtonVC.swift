import UIKit

class FloatButtonVC: UIViewController {

    var overlayWindow: UIWindow?
    var isVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        btn.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 0.9)
        btn.layer.cornerRadius = 22
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.4
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.setTitle("📝", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 22)
        btn.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        view.addSubview(btn)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        btn.addGestureRecognizer(pan)
    }

    @objc func toggle() {
        if overlayWindow == nil {
            overlayWindow = UIWindow(frame: CGRect(x: 20, y: 120, width: 300, height: 220))
            overlayWindow?.windowLevel = UIWindow.Level.alert + 50
            overlayWindow?.backgroundColor = .clear
            overlayWindow?.layer.cornerRadius = 14
            overlayWindow?.clipsToBounds = true
            overlayWindow?.rootViewController = MemoViewController()
        }
        isVisible.toggle()
        overlayWindow?.isHidden = !isVisible
        if isVisible { overlayWindow?.makeKeyAndVisible() }
    }

    @objc func onPan(_ g: UIPanGestureRecognizer) {
        guard let win = view.window else { return }
        let t = g.translation(in: win)
        var f = win.frame
        let screen = UIScreen.main.bounds
        f.origin.x = max(0, min(f.origin.x + t.x, screen.width - 44))
        f.origin.y = max(60, min(f.origin.y + t.y, screen.height - 100))
        win.frame = f
        g.setTranslation(.zero, in: win)
    }
}
