import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    //MARK: - UI elements
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let data = ["Log Out"]
    
    //MARK: - Lifecycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .systemRed
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheeet = UIAlertController(title: nil,
                                             message: nil,
                                             preferredStyle: .actionSheet)
        actionSheeet.addAction(UIAlertAction(title: "Log Out",
                                             style: .destructive,
                                             handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            // Log out Facebook
            FBSDKLoginKit.LoginManager().logOut()
            
            // Sign out Google
            GIDSignIn.sharedInstance.signOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                strongSelf .present(navController, animated: true)
                
            } catch {
                print("Failed to log out")
            }
        }))
        
        actionSheeet.addAction(UIAlertAction(title: "Cancel",
                                             style: .cancel,
                                             handler: nil))
        
        self.present(actionSheeet, animated: true, completion: nil)
    }
    
}
