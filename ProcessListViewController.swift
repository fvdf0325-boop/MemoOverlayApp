import UIKit
import Darwin

class ProcessListViewController: UIViewController,
                                  UITableViewDelegate,
                                  UITableViewDataSource,
                                  UISearchResultsUpdating {

    var onSelect: ((String, Int32) -> Void)?
    var processes: [(name: String, pid: Int32)] = []
    var filtered: [(name: String, pid: Int32)] = []
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "프로세스 목록"
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1)

        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "프로세스 검색..."
        navigationItem.searchController = search

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "↺", style: .plain, target: self, action: #selector(refresh))

        tableView = UITableView(frame: view.bounds)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        refresh()
    }

    @objc func refresh() {
        processes = getProcessList()
        filtered = processes
        tableView.reloadData()
    }

    func getProcessList() -> [(name: String, pid: Int32)] {
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0]
        var size = 0
        sysctl(&mib, 4, nil, &size, nil, 0)
        let count = size / MemoryLayout<kinfo_proc>.stride
        var procs = [kinfo_proc](repeating: kinfo_proc(), count: count)
        sysctl(&mib, 4, &procs, &size, nil, 0)
        return procs.compactMap { p in
            var proc = p
            let name = withUnsafeBytes(of: &proc.kp_proc.p_comm) { buf in
                String(bytes: buf.prefix(while: { $0 != 0 }), encoding: .utf8) ?? ""
            }
            let pid = proc.kp_proc.p_pid
            guard !name.isEmpty, pid > 0 else { return nil }
            return (name: name, pid: pid)
        }.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        filtered = text.isEmpty ? processes : processes.filter {
            $0.name.lowercased().contains(text.lowercased())
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let proc = filtered[indexPath.row]
        cell.textLabel?.text = proc.name
        cell.detailTextLabel?.text = "PID: \(proc.pid)"
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = UIColor(white: 1, alpha: 0.4)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let proc = filtered[indexPath.row]
        onSelect?(proc.name, proc.pid)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}
