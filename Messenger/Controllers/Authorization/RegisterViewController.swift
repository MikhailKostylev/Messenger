import UIKit

class RegisterViewController: UIViewController {
    
    //MARK: - UI elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.backgroundColor = .white
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.placeholder = "First Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.roundCorners()
        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.placeholder = "Last Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.roundCorners()
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.roundCorners()
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        field.roundCorners()
        return field
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.roundCorners()
        return button
    }()
    
    //MARK: - Lifecycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Register"
        //FIXME: - do this
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        registerButton.addTarget(self,
                              action: #selector(registerButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        //Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        scrollView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        firstNameField.frame = CGRect(x: 30,
                                  y: imageView.bottom+20,
                                  width: scrollView.width-60,
                                  height: 52)
        
        lastNameField.frame = CGRect(x: 30,
                                  y: firstNameField.bottom+20,
                                  width: scrollView.width-60,
                                  height: 52)
        
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom+20,
                                  width: scrollView.width-60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+20,
                                     width: scrollView.width-60,
                                     height: 52)
        
        registerButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+30,
                                   width: scrollView.width-60,
                                   height: 52)
        registerButton.dropShadow()
        imageView.layer.cornerRadius = imageView.width/2
    }
    
    //MARK: - Action funcs
    @objc func didTapChangeProfilePic() {
        print("Change Pic")
        //TODO: - do this
    }
    
    @objc private func didTapRegister() {
        let registerVC = RegisterViewController()
        registerVC.title = "Create Account"
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc private func registerButtonTapped() {
        
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        do {
            try login()
            // Transition to next screen
        } catch LoginError.incompleteForm {
            Alert.showBasic(title: "Incomplete Form", message: "Please enter all information to create new account" , vc: self, view: self.view)
        } catch LoginError.invalidEmail {
            Alert.showBasic(title: "Invalid Email Format", message: "Please make sure you format your email correctly", vc: self, view: self.view)
        } catch LoginError.incorrectPasswordLength {
            Alert.showBasic(title: "Password Too Short", message: "Password should be at least 6 characters", vc: self, view: self.view)
        } catch {
            Alert.showBasic(title: "Unable To Register", message: "There was an error when attempting to register", vc: self, view: self.view)
        }
    }
    //MARK: - Logic funcs
    private func login() throws {
        let email = emailField.text!
        let password = passwordField.text!
        let firstName = firstNameField.text!
        let lastName = lastNameField.text!
        
        if firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty {
            throw LoginError.incompleteForm
        }
        if !email.isValidEmail {
            throw LoginError.invalidEmail
        }
        if password.count < 6 {
            throw LoginError.incorrectPasswordLength
        }
        // Firabase Log In
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        }
        else if textField == lastNameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            registerButtonTapped()
        }
        
        return true
    }
}
