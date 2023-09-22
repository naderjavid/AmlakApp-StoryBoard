//
//  LoginViewController.swift
//  AmlakApp
//
//  Created by nader on 6/31/1402 AP.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var isLoggingIn = false
    private var isLoggedIn = false
    private var isUserExists = false
    private var isRefreshingToken = true
    private var showAlert = false
    private var alertMessage = ""
    
    @IBAction func Login(_ sender: Any) {
        
        isLoggingIn = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        NetworkManager.shared.login(username: userName.text!, password: password.text!) { [self] result in
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }

            switch result {
            case .success:
                self.isLoggedIn = true
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goToMelks", sender: self)
                }
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async {
                    
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
            
            self.isLoggingIn = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        self.activityIndicator.isHidden = true
        // Do any additional setup after loading the view.
        if let user = currentUser {
            
            self.userName.text = user.username
            
            isRefreshingToken = true
            isUserExists = true
            if user.accessTokenExpirationDate <= Date() {
                // Token is not valid, attempt to refresh it
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()
                }
                NetworkManager.shared.refreshToken { result in
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        
                    }
                    switch result {
                    case .success(let user):
                        self.isLoggedIn = true
                        // Token refreshed successfully
                        break // Continue to RealEstateListView
                    case .failure(let error):
                        self.isRefreshingToken = false
                        self.isUserExists = false // Navigate to the login page
                        self.alertMessage = error.localizedDescription
                        self.showAlert.toggle()
                    }
                }
            }
            else {
                isLoggedIn = true
                currentUser = user
                performSegue(withIdentifier: "goToMelks", sender: self)
            }
        }
        else {
            isRefreshingToken = false
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
