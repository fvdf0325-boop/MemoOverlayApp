import UIKit

class MemoViewController: UIViewController, UITextViewDelegate {

    var textView: UITextView!
    let memoPath = "/var/mobile/Documents/overlay_memo.txt"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 0.92)
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor(white: 1, alpha: 0.2).cgColor

        let bar = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 36))
        bar.backgroundColor = UIColor(white: 1, alpha: 0.05)

        let title = UILabel(frame: CGRect(x: 12, y: 0, width: 120, height: 36))
        title.text = "📝 메모"
        title.textColor = .white
        title.font = .boldSystemFont(ofSize: 13)
        bar.addSubview(title)

        let procBtn = UIButton(frame: CGRect(x: view.bounds.width - 72, y: 0, width: 36, height: 36))
        procBtn.setTitle("⚙️", for: .normal)
        procBtn.titleLabel?.font = .systemFont(ofSize: 16)
        procBtn.addTarget(self, action: #selector(showProcessList), for: .touchUpInside)
        bar.addSubview(procBtn)

        let closeBtn = UIButton(frame: CGRect(x: view.bounds.width - 36, y: 0, width: 36, height: 36))
        closeBtn.setTitle("✕", for: .normal)
        closeBtn.titleLabel?.font = .systemFont(ofSize: 14)
        closeBtn.setTitleColor(UIColor(white: 1, alpha: 0.6), for: .normal)
        closeBtn.addTarget(self, action: #selector(hide), for: .touchUpInside)
        bar.addSubview(closeBtn)
        view.addSubview(bar)

        textView = UITextView(frame: CGRect(x: 8, y: 40,
                                            width: view.bounds.width - 16,
                                            height: view.bounds.height - 48))
        textView.backgroundColor = .clear
        textView.textColor = UIColor(white: 0.95, alpha: 1)
        textView.font = .systemFont(ofSize: 14)
        textView.text = loadMemo()
        textView.delegate = self
        textView.keyboardAppearance = .dark
        view.addSubview(textView)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        bar.addGestureRecognizer(pan)
    }

    @objc func showProcessList() {
        let vc = ProcessListViewController()
        vc.onSelect = { [weak self] name, pid in
            guard let tv = self?.textView else { return }
            let insert = "[\(name)(PID:\(pid))] "
            let pos = tv.selectedRange.location
            var text = tv.text ?? ""
            let idx = text.index(text.startIndex, offsetBy: min(pos, text.count))
            text.insert(contentsOf: insert, at: idx)
            tv.text = text
            self?.saveMemo()
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    @objc func hide() {
        view.window?.isHidden = true
    }

    @objc func onPan(_ g: UIPanGestureRecognizer) {
        guard let win = view.window else { return }
        let t = g.translation(in: win)
        var f = win.frame
        let screen = UIScreen.main.bounds
        f.origin.x = max(0, min(f.origin.x + t.x, screen.width - f.width))
        f.origin.y = max(0, min(f.origin.y + t.y, screen.height - f.height))
        win.frame = f
        g.setTranslation(.zero, in: win)
    }

    func textViewDidChange(_ textView: UITextView) { saveMemo() }

    func saveMemo() {
        try? textView.text.write(toFile: memoPath, atomically: true, encoding: .utf8)
    }

    func loadMemo() -> String {
        return (try? String(contentsOfFile: memoPath, encoding: .utf8)) ?? ""
    }
}
