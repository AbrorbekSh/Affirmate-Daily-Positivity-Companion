import UIKit

class Attitudes{
    static var attitudes: [AttitudeStruct] = []
}

final class AttitudesViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        attitudesTableView.frame  = view.bounds
        activateLayout()
    }
    
    // MARK: - Layout
    
    private func setupView() {
        addSubviews()
        configureNavBar()
        configureTableView()
        configureButtons()
    }

    // MARK: - Private Methods
    
    private func configureButtons(){
        addButton.addTarget(self, action: #selector(addAttitude), for: .touchUpInside)
    }
    
    private func addSubviews(){
        [attitudesTableView, addButton].forEach{
            view.addSubview($0)
        }
    }
    
    private func configureTableView(){
        attitudesTableView.delegate = self
        attitudesTableView.dataSource = self
    }
    
    private func configureNavBar(){
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 25)!]
        
        title = "Attitudes"
        let image = UIImage(systemName: "list.bullet")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        
        let image2 = UIImage(systemName: "gearshape")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: image2, style: .done, target: self, action: nil)
        ]
    }
    
    private func activateLayout(){
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -45),
            addButton.heightAnchor.constraint(equalToConstant: 55),
            addButton.widthAnchor.constraint(equalToConstant: 55),
        ])
    }
    
    // MARK: - UI Elements
    
    let attitudesTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        table.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        
        return table
     }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "plus",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        config.cornerStyle = .capsule
        button.configuration = config
        button.tintColor = .systemBlue
        
        return button
    }()
    
    // MARK: - @objc methods
    
    @objc private func addAttitude(){
        let vc = NewAttitudeViewController()
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        vc.delegate = self
        present(nav, animated: true, completion: nil)
    }
}

extension AttitudesViewController: UITableViewDataSource, UITableViewDelegate{

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Attitudes.attitudes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let counterViewController = CounterViewController(attitude: Attitudes.attitudes[indexPath.row].attitude, header: Attitudes.attitudes[indexPath.row].header, aim: Attitudes.attitudes[indexPath.row].counter)
        navigationItem.backBarButtonItem?.title = ""
        navigationController?.pushViewController(counterViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = view.frame.height/10+10
        return CGFloat(size)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as?     CustomTableViewCell else {
                return UITableViewCell()
            }
        cell.headerLabel.text = Attitudes.attitudes[indexPath.row].header
        cell.layer.cornerRadius = cell.frame.height/4.0
        cell.selectionStyle = .none
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.bottom
        let offset = scrollView.contentOffset.y + defaultOffset
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}

extension AttitudesViewController: UpdateTableViewProtocol {
    func updateTableView() {
        attitudesTableView.reloadData()
    }
}

