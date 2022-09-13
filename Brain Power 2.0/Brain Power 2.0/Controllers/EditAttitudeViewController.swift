
import UIKit
import CoreData

protocol UpdateTableViewAfterEditProtocol: AnyObject{
    func updateTableViewAfterEdit()
}

final class EditAttitudeViewController: UIViewController {
    
    // MARK: - Properties
    let header: String
    let attitude: String
    let counter: Int
    let indexPath: Int
    init(header: String, attitude: String, counter: Int, indexPath: Int){
        self.header = header
        self.attitude = attitude
        self.counter = counter
        self.indexPath = indexPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: UpdateTableViewAfterEditProtocol?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    // MARK: - Layout
    
    private func setupView() {
        addSubviews()
        configureNavBar()
        configureTextFields()
        configureButtons()
        
        activateLayout()
        
        view.backgroundColor = .white
    }
    
    // MARK: - Private Methods
    
    private func addSubviews() {
        view.addSubview(headerLabel)
        view.addSubview(headerTextField)
        view.addSubview(attitudeLabel)
        view.addSubview(attitudeTextView)
        view.addSubview(counterLabel)
        view.addSubview(counterTextField)
        view.addSubview(readyButton)
    }
    
    private func configureNavBar(){
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 25)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        title = "Изменить"
        
        let image = UIImage(systemName: "xmark")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(dismissButton))
    }
    
    private func configureTextFields() {
        attitudeTextView.delegate = self
        headerTextField.delegate = self
        counterTextField.delegate = self
    }
    
    private func configureButtons() {
        readyButton.addTarget(self, action: #selector(readyButtonPressed), for: .touchUpInside)
    }
    
    private func activateLayout(){
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 90),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerLabel.heightAnchor.constraint(equalToConstant: 56),
            headerLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 60),
            
            headerTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            headerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerTextField.heightAnchor.constraint(equalToConstant: 40),
            headerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            attitudeLabel.topAnchor.constraint(equalTo: headerTextField.bottomAnchor, constant: 30),
            attitudeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            attitudeLabel.heightAnchor.constraint(equalToConstant: 56),
            attitudeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 60),
            
            attitudeTextView.topAnchor.constraint(equalTo: attitudeLabel.bottomAnchor),
            attitudeTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            attitudeTextView.heightAnchor.constraint(equalToConstant: 200),
            attitudeTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            counterLabel.topAnchor.constraint(equalTo: attitudeTextView.bottomAnchor, constant: 30),
            counterLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            counterLabel.heightAnchor.constraint(equalToConstant: 56),
            counterLabel.widthAnchor.constraint(equalToConstant: 260),
            
            counterTextField.topAnchor.constraint(equalTo: attitudeTextView.bottomAnchor, constant: 40),
            counterTextField.leadingAnchor.constraint(equalTo: counterLabel.trailingAnchor, constant: 10),
            counterTextField.heightAnchor.constraint(equalToConstant: 40),
            counterTextField.widthAnchor.constraint(equalToConstant: 60),
            
            readyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            readyButton.bottomAnchor.constraint(equalTo: counterTextField.bottomAnchor, constant: view.bounds.size.height/6.5),
            readyButton.heightAnchor.constraint(equalToConstant: 65),
            readyButton.widthAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    @objc private func readyButtonPressed(){
        
        if attitudeTextView.textColor == .lightGray {
            attitudeTextView.layer.borderColor = UIColor.systemRed.cgColor
            attitudeTextView.layer.borderWidth = 0.5
        }
        
        if attitudeTextView.text == "" {
            attitudeTextView.layer.borderColor = UIColor.systemRed.cgColor
            attitudeTextView.layer.borderWidth = 0.5
        }
        
        if counterTextField.text == "" {
            counterTextField.layer.borderColor = UIColor.systemRed.cgColor
            counterTextField.layer.borderWidth = 0.5
        }
        
        if headerTextField.text == "" {
            headerTextField.layer.borderColor = UIColor.systemRed.cgColor
            headerTextField.layer.borderWidth = 0.5
        }
        
        if attitudeTextView.textColor != .lightGray && attitudeTextView.text != "" && counterTextField.text != "" && headerTextField.text != ""{
            let newAttitude = Attitude(context: context)
            newAttitude.header = headerTextField.text!
            newAttitude.counter = Int16(Int32(Int(counterTextField.text!)!))
            newAttitude.attitude = attitudeTextView.text!
            
            context.delete(Attitudes.attitudes[indexPath])
            Attitudes.attitudes.remove(at: indexPath)
            Attitudes.attitudes.insert(newAttitude, at: indexPath)
            do{
                try context.save()
            } catch {
                print("Error with \(error)")
            }
            delegate?.updateTableViewAfterEdit()
            dismiss(animated: true)
        }
        
    }
    
    @objc private func dismissButton(){
        dismiss(animated: true)
    }
    
    // MARK: - UI Elements
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Название"
        label.font = UIFont(name: "Montserrat-Medium", size: 22)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var headerTextField: UITextField = {
        let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        
        text.text = "\(header)"
        text.attributedPlaceholder = NSAttributedString(
            string: "Например: Карьера",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        text.textColor = .black
        text.font = UIFont(name: "Montserrat-Regular", size: 20)
        text.backgroundColor = UIColor(hexString: "f4f4f4")
        text.layer.cornerRadius = 4
        
        return text
    }()
    
    private let attitudeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Установка"
        label.font = UIFont(name: "Montserrat-Medium", size: 22)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var attitudeTextView: UITextView = {
        let text = UITextView()
        text.translatesAutoresizingMaskIntoConstraints = false
        
        text.backgroundColor = .white
        text.textColor = .black
        text.text = "\(attitude)"
        text.font = UIFont(name: "Montserrat-Regular", size: 20)
        text.backgroundColor = UIColor(hexString: "f4f4f4")
        text.layer.cornerRadius = 4
        text.showsVerticalScrollIndicator = false
        
        return text
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Количество"
        label.font = UIFont(name: "Montserrat-Medium", size: 22)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var counterTextField: UITextField = {
        let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        
        text.textColor = .black
        text.attributedPlaceholder = NSAttributedString(
            string: "100",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        text.text = "\(counter)"
        text.font = UIFont(name: "Montserrat-Regular", size: 25)
        text.backgroundColor = UIColor(hexString: "f4f4f4")
        text.layer.cornerRadius = 4
        text.keyboardType = .numberPad
        text.textAlignment = .center
        
        return text
    }()
    
    private let readyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Готово", for: .normal)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        
        return button
    }()
    
}

// MARK: - UITextViewDelegate

extension EditAttitudeViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText = textView.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return updatedText.count <= 200
    }
    
    func textViewDidBeginEditing (_ textView: UITextView) {
        if attitudeTextView.textColor == .lightGray && attitudeTextView.isFirstResponder {
            attitudeTextView.text = nil
            attitudeTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing (_ textView: UITextView) {
        if attitudeTextView.text.isEmpty || attitudeTextView.text == "" {
            attitudeTextView.textColor = .lightGray
            attitudeTextView.text = "Например: Я рада, что стала начальником отдела аренды."
        }
    }
    
}

// MARK: - UITextFieldDelegate

extension EditAttitudeViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if counterTextField.isFirstResponder {
            if textField.text?.count == 0 && string == "0" {
                return false
            }
            
            if ((textField.text!) + string).count > 3 {
                return false
            }
            
            let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789.")
            let textCharacterSet = CharacterSet.init(charactersIn: textField.text! + string)
            
            if !allowedCharacterSet.isSuperset(of: textCharacterSet) {
                return false
            }
            
            return true
        } else if headerTextField.isFirstResponder {
            let maxLength = 40
            let currentString = (textField.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: string)
            
            return newString.count <= maxLength
        }
        
        return true
    }
    
}
