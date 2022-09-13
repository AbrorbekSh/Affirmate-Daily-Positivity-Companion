import UIKit

class CounterViewController: UIViewController {
    
    // MARK: - Properties
    
    let defaults = UserDefaults.standard
    var counter: Int = 0
    let attitude: String
    let header: String
    let aim : Int
    
    // MARK: - Lifecycle
    
    init(attitude: String, header: String, aim: Int){
        self.attitude = attitude
        self.header = header
        self.aim = aim
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradient = makeGradient()
        
        view.layer.addSublayer(gradient)
        configureNavBar()
        
        if defaults.object(forKey: "\(attitude)"+"\(header)"+"\(aim)") == nil {
            defaults.set(counter, forKey: "\(attitude)"+"\(header)"+"\(aim)")
            completedLabel.isHidden = true
        } else {
            counter = defaults.integer(forKey: "\(attitude)"+"\(header)"+"\(aim)")
            if counter < aim {
                completedLabel.isHidden = true
            } else {
                completedLabel.isHidden = false
            }
        }
        
        [minusButton, plusButton, refreshButton, counterLabel, attitudeTextLabel, aimLabel, completedLabel].forEach({view.addSubview($0)})
        plusButton.addTarget(self, action: #selector(increaseCounter), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(decreaseCounter), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refreshCounter), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        activateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    // MARK: - Layout
    
    // MARK: - Private Methods
    
    private func configureNavBar(){
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 20)!]
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        title = "\(header)"
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    private func makeGradient() -> CAGradientLayer{
        let gradient = CAGradientLayer()
//        #ee9ca7 → #ffdde1 Pink gradient
        gradient.frame = view.bounds
        let color1 = UIColor(hexString: "#2193b0")
        let color2 = UIColor(hexString: "#6dd5ed")
        gradient.colors = [
            color1.cgColor,
            color2.cgColor,
        ]
        return gradient
    }
    
    private func activateLayout(){
        NSLayoutConstraint.activate([
            plusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            plusButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.bounds.size.height/5 + 70),
            plusButton.heightAnchor.constraint(equalToConstant: 160),
            plusButton.widthAnchor.constraint(equalToConstant: 160),
            
            minusButton.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -50),
            minusButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.bounds.size.height/5 + 20 ),
            minusButton.heightAnchor.constraint(equalToConstant: 75),
            minusButton.widthAnchor.constraint(equalToConstant: 75),

            refreshButton.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor),
            refreshButton.bottomAnchor.constraint(equalTo: plusButton.topAnchor, constant: 0),
            refreshButton.heightAnchor.constraint(equalToConstant: 60),
            refreshButton.widthAnchor.constraint(equalToConstant: 60),
            
            counterLabel.bottomAnchor.constraint(equalTo: refreshButton.topAnchor),
            counterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterLabel.heightAnchor.constraint(equalToConstant: 120),
            
            attitudeTextLabel.bottomAnchor.constraint(equalTo: counterLabel.topAnchor, constant: -view.bounds.size.height/10),
            attitudeTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            attitudeTextLabel.heightAnchor.constraint(equalToConstant: view.bounds.size.height/3 - 80),
            attitudeTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            aimLabel.bottomAnchor.constraint(equalTo: plusButton.topAnchor, constant: -20),
            aimLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            aimLabel.heightAnchor.constraint(equalToConstant: 50),
            aimLabel.widthAnchor.constraint(equalToConstant: 100),
            
            completedLabel.bottomAnchor.constraint(equalTo: counterLabel.topAnchor, constant: -10),
            completedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completedLabel.heightAnchor.constraint(equalToConstant: 50),
            completedLabel.widthAnchor.constraint(equalToConstant: 270),
        ])
    }
    
    
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.text = "\(counter)"
        label.font = UIFont(name: "Montserrat-Bold", size: 100)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()
    
    private lazy var aimLabel: UILabel = {
        let label = UILabel()
        label.text = "/\(aim)"
        label.font = UIFont(name: "Montserrat-Regular", size: 40)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()
    
    private let completedLabel: UILabel = {
        let label = UILabel()
        label.text = "Завершено!"
        label.font = UIFont(name: "Montserrat-Bold", size: 40)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemGreen
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 7
        label.textAlignment = .center
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "plus.circle",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 140, weight: .thin))
        config.cornerStyle = .capsule
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .clear
        return button
    }()
    
    private let minusButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "minus.circle",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 80, weight: .light))
        config.cornerStyle = .capsule
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .clear
        return button
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "arrow.clockwise.circle",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .regular))
        config.cornerStyle = .capsule
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .clear
        return button
    }()
    
    private lazy var attitudeTextLabel: UILabel = {
        
        let text = UILabel()
        text.backgroundColor = .white
        text.textColor = .black
        text.text = "\(attitude)"
        text.font = UIFont(name: "Montserrat-Regular", size: 20)
        text.backgroundColor = UIColor(hexString: "f4f4f4")
        text.layer.masksToBounds = true
        text.layer.cornerRadius = 10
        text.translatesAutoresizingMaskIntoConstraints = false
        text.layer.opacity = 0.7
        text.lineBreakMode = .byWordWrapping
        text.numberOfLines = 7
        text.textAlignment = .center
        return text
    }()
    
    @objc private func increaseCounter(){
        if counter < 10000 {
            counter = (counter + 1)
            counterLabel.text = "\(counter)"
            if counter >= aim {
                completedLabel.isHidden = false
            }
            if counter == aim {
                HapticsManager.shared.vibrate(for: .success)
            } else{
                HapticsManager.shared.selectionVibrate()
            }
            defaults.set(counter, forKey: "\(attitude)"+"\(header)"+"\(aim)")
        }
    }
    
    @objc private func decreaseCounter(){
        if counter > 0 {
            counter = counter - 1
            counterLabel.text = "\(counter)"
            if counter < aim {
                completedLabel.isHidden = true
            }
            defaults.set(counter, forKey: "\(attitude)"+"\(header)"+"\(aim)")
        } else {
            HapticsManager.shared.vibrate(for: .error)
        }
    }
    
    @objc private func refreshCounter(){
        counter = 0
        completedLabel.isHidden = true
        defaults.set(counter, forKey: "\(attitude)"+"\(header)"+"\(aim)")
        counterLabel.text = "\(counter)"
    }
}
