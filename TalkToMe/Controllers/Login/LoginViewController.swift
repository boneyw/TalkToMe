//
//  LoginViewController.swift
//  TalkToMe
//
//  Created by william boney on 3/23/22.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        
        return scrollView
        
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.backgroundColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x:0, y:0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
        
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.backgroundColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x:0, y:0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        
        return field
        
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()
    
    private let faceloginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email,public_profile"]
        return button
        
    }()
    
    private let googleloginButton: GIDSignInButton = {
        let button = GIDSignInButton()

        return button
    }()
    
    
    
    private let imageview: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        faceloginButton.delegate = self
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageview)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(faceloginButton)
        scrollView.addSubview(googleloginButton)
        
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageview.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageview.bottom+10,
                                  width: scrollView.width-60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+10,
                                     width: scrollView.width-60,
                                     height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
        
        faceloginButton.frame = CGRect(x: 30,
                                   y: loginButton.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
        
        googleloginButton.frame = CGRect(x: 30,
                                   y: faceloginButton.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
        
        
        
        
    }
    
    @objc private func didTapRegister(){
        let vc = RegViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Woops",
                                      message: "Plese enter all information to log in ",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
    }
    
    @objc private func loginButtonTapped(){
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else{
            
            alertUserLoginError()
            return
        }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf  = self else{
                return
            }
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email: \(email)")
                return
            }
            
            let user = result.user
            print("Logged in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
        })
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            loginButtonTapped()
        }
        return true
    }
    
}

extension LoginViewController: LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //no Operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with FaceBook ID")
            return
        }
        
        let fbRequest  = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                    parameters: ["fields": "email, name" ],
                                                    tokenString: token,
                                                    version: nil,
                                                    httpMethod: .get)
        
        fbRequest.start(completion: {_, result, error in
            guard let result = result as? [String:Any], error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            
            print ("\(result)")
            
            guard let username = result ["name"] as? String,
                  let email = result["email"] as? String else {
                print("Failed to get email and name form fb result")
                return
            }
            
            
            let namecompontents = username.components(separatedBy: " ")
            guard namecompontents.count  == 2 else{
                return
            }
            
            let firstName = namecompontents[0]
            let lastName = namecompontents[1]
            
            DatabaseManager.shared.userExists(with: email, completion: {exists in
                if !exists {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstname: firstName,
                                                                        lastname: lastName,
                                                                        emailAddress: email))
                }})
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [ weak self ] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else {
                    
                    if let error = error {
                        print("Facebook credential login failed MFA may be needed - \(error)")
                    }
                    
                    
                    return
                }
                
                print("SuccessFully Logged user ")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
            
            
        })
    }
    
        
    
}
