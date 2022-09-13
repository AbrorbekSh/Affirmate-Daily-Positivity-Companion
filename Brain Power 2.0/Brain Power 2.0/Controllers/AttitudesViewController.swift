import UIKit
import CoreData

class Attitudes{
    static var attitudes: [Attitude] = []
}

final class AttitudesViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        
        let request : NSFetchRequest<Attitude> = Attitude.fetchRequest()
        do {
            Attitudes.attitudes = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        attitudesTableView.frame  = view.bounds
        activateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            configureNavBar()
    }
    
    // MARK: - Layout
    
    private func setupView() {
        
        addSubviews()
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
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 25)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.tintColor = .black
        
        title = "Установки"

//        let image = UIImage(systemName: "list.bullet")?.withTintColor(.black, renderingMode: .alwaysOriginal)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
//        
//        let image2 = UIImage(systemName: "gearshape")?.withTintColor(.black, renderingMode: .alwaysOriginal)
//        navigationItem.rightBarButtonItems = [
//            UIBarButtonItem(image: image2, style: .done, target: self, action: nil)
//        ]
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
        table.backgroundColor = .white
        
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {
            (action, sourceView, completionHandler) in
            self.context.delete(Attitudes.attitudes[indexPath.row])
            Attitudes.attitudes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            do{
                try self.context.save()
            } catch {
                print("Error with \(error)")
            }
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let editAction = UIContextualAction(style: .normal, title: "Изменить") {
            (action, sourceView, completionHandler) in
            // 1. Segue to Edit view MUST PASS INDEX PATH as Sender to the prepareSegue function
            let vc = EditAttitudeViewController(header: Attitudes.attitudes[indexPath.row].header!, attitude: Attitudes.attitudes[indexPath.row].attitude!, counter: Int(Attitudes.attitudes[indexPath.row].counter), indexPath: indexPath.row)
            vc.delegate = self
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            completionHandler(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemOrange
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [ deleteAction, editAction])
        // Delete should not delete automatically
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Attitudes.attitudes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let counterViewController = CounterViewController(attitude: Attitudes.attitudes[indexPath.row].attitude!, header: Attitudes.attitudes[indexPath.row].header!, aim: Int(Attitudes.attitudes[indexPath.row].counter))
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
        cell.backgroundColor = .white
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

extension AttitudesViewController: UpdateTableViewAfterEditProtocol {
    func updateTableViewAfterEdit() {
        attitudesTableView.reloadData()
    }
}


