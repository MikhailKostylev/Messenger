import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}

enum ProfileViewModelType {
    case info, logout
}

class ProfileViewController: UIViewController {
    
    //MARK: - UI elements
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var data = [ProfileViewModel]()
    
    //MARK: - Lifecycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.register(ProfileTableViewCell.self,
                           forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.tableHeaderView = createTableHeader()
        tableView.delegate = self
        tableView.dataSource = self
        
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "\(UserDefaults.standard.value(forKey: Keys.name.rawValue) as? String ?? "No Name")",
                                     handler: nil))
        
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "\(UserDefaults.standard.value(forKey: Keys.email.rawValue) as? String ?? "No Email")",
                                     handler: nil))
        
        data.append(ProfileViewModel(viewModelType: .logout, title: "Log Out", handler: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            let actionSheeet = UIAlertController(title: nil,
                                                 message: nil,
                                                 preferredStyle: .actionSheet)
            actionSheeet.addAction(UIAlertAction(title: "Log Out", style: .destructive,handler: { [weak self] _ in
                
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
                    strongSelf.present(navController, animated: true)
                    
                } catch {
                    print("Failed to log out")
                }
            }))
            
            actionSheeet.addAction(UIAlertAction(title: "Cancel",
                                                 style: .cancel,
                                                 handler: nil))
            
            strongSelf.present(actionSheeet, animated: true, completion: nil)
        }))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: - Logic funcs
    private func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: Keys.email.rawValue) as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: view.width,
                                              height: 300))
        headerView.backgroundColor = .systemBackground
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150)/2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                imageView.sd_setImage(with: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        }
        
        return headerView
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier,
                                                       for: indexPath) as? ProfileTableViewCell else {
            return UITableViewCell()
        }
        
        let viewModel = data[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
}
