import UIKit
import FirebaseAuth
import FirebaseCore
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD
import SwiftUI

class LoginViewController: UIViewController {
    
    //MARK: - UI elements
    private let spinner = JGProgressHUD(style: .extraLight)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .next
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemGray.cgColor
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
        field.layer.borderColor = UIColor.systemGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        field.roundCorners()
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .link
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.roundCorners()
        return button
    }()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email","public_profile"]
        return button
    }()
    
    private let googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.style = .wide
        button.colorScheme = .dark
        return button
    }()
    
    //MARK: - Lifecycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup VC
        hideKeyboardWhenTappedAround()
        view.backgroundColor = .white
        title = "Log In"
        
        //Add targets
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        googleLoginButton.addTarget(self,
                                    action: #selector(googleLogInTapped),
                                    for: .touchUpInside)
        // Delegates
        emailField.delegate = self
        passwordField.delegate = self
        facebookLoginButton.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Configure UI elements
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+20,
                                  width: scrollView.width-60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+20,
                                     width: scrollView.width-60,
                                     height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+30,
                                   width: scrollView.width-60,
                                   height: 52)
        loginButton.addGradient(color1: UIColor.cyan.cgColor, color2: UIColor.link.cgColor)
        loginButton.dropShadow()
        
        facebookLoginButton.frame = CGRect(x: 30,
                                           y: loginButton.bottom+30,
                                           width: scrollView.width-60,
                                           height: 52)
        
        googleLoginButton.frame = CGRect(x: 30,
                                         y: facebookLoginButton.bottom+20,
                                         width: scrollView.width-60,
                                         height: 52)
    }
    
    //MARK: - Action funcs
    @objc private func didTapRegister() {
        let registerVC = RegisterViewController()
        registerVC.title = "Create Account"
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc private func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        do {
            try mainLogin()
            // Transition to next screen
        } catch LoginError.incompleteForm {
            Alert.showBasic(title: "Incomplete Form", message: "Please fill out both email and password fields" , vc: self, view: self.view)
        } catch LoginError.invalidEmail {
            Alert.showBasic(title: "Invalid Email Format", message: "Please make sure you format your email correctly", vc: self, view: self.view)
        } catch LoginError.incorrectPasswordLength {
            Alert.showBasic(title: "Password Too Short", message: "Password should be at least 6 characters", vc: self, view: self.view)
        } catch {
            Alert.showBasic(title: "Unable To Login", message: "There was an error when attempting to login", vc: self, view: self.view)
        }
    }
    
    @objc private func googleLogInTapped() {
        googleLogIn()
    }
    
    //MARK: - Main Log In (Firebase)
    private func mainLogin() throws {
        guard let email = emailField.text, let password = passwordField.text else {
            return
        }
        
        if email.isEmpty || password.isEmpty {
            throw LoginError.incompleteForm
        }
        if !email.isValidEmail {
            throw LoginError.invalidEmail
        }
        if password.count < 6 {
            throw LoginError.incorrectPasswordLength
        }
        
        spinner.show(in: view)
        
        // Firabase Log In
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                Alert.showBasic(title: "Incorrect Email or Password", message: "Please check your details and try again", vc: strongSelf, view: strongSelf.view)
                print("Failed to log in")
                return
            }
            
            let user = result.user
            
            UserDefaults.standard.set(email, forKey: Keys.email.rawValue)
            
            print("Logged In User: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Google Log In
    private func googleLogIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Google Sign In
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            
            guard let email = user?.profile?.email,
                  let firstName = user?.profile?.givenName,
                  let lastName = user?.profile?.familyName else {
                      return
                  }
            
            UserDefaults.standard.set(email, forKey: Keys.email.rawValue)
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser) { success in
                        if success {
                            
                            // upload image
                            
                            if ((user?.profile?.hasImage) != nil) {
                                guard let url = user?.profile?.imageURL(withDimension: 200) else {
                                    return
                                }
                                
                                URLSession.shared.dataTask(with: url) { data, _, _ in
                                    guard let data = data else {
                                        return
                                    }
                                    
                                    let filename = chatUser.profilePictureFileName
                                    StorageManager.shared.uploadProfilePicture(with: data,
                                                                               filename: filename) { result in
                                        switch result {
                                        case .success(let downloadUrl):
                                            UserDefaults.standard.set(downloadUrl, forKey: Keys.profilePictureUrl.rawValue)
                                            print(downloadUrl)
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                }.resume()
                            }
                        }
                    }
                }
            }
            
            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken else {
                      return
                  }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Failed to sign in with Google: \(error)")
                    }
                    return
                }
                print("Successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

//MARK: - Textfield Delegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
}

//MARK: - Facebook Log In
extension LoginViewController: LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
    }
    
    // Facebook Log In
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failded to log in with facebook")
            return
        }
        
        spinner.show(in: view)
        
        let facebooKRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields":
                                                                        "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebooKRequest.start { _,  result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            
            print(result)
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String else {
                      print("Failde to get name and email from fb result")
                      return
                  }
            
            UserDefaults.standard.set(email, forKey: Keys.email.rawValue)
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser) { success in
                        if success {
                            
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            print("Downloading data from facebook image")
                            
                            URLSession.shared.dataTask(with: url) { data, _, _ in
                                guard let data = data else {
                                    print("Failed to get data from facebook")
                                    return
                                }
                                
                                print("Got data from facebook, uploading...")
                                
                                // upload image
                                let filename = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data,
                                                                           filename: filename) { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: Keys.profilePictureUrl.rawValue)
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            }.resume()
                        }
                    }
                }
            }
            // Firebase authorization with facebook's credential
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                }
                
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Failed to sign in with Facebook: \(error)")
                    }
                    return
                }
                print("Successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
