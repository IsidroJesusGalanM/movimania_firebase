//
//  ViewController.swift
//  movimania_firebase
//
//  Created by usuario on 26/12/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreData
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

class ViewController: UIViewController {
    
    var db: Firestore!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var botonLogin: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfLogged()
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        

    }

    @IBAction func Registrarse(_ sender: Any) {
        
        let secondViewController = RegisterView(nibName: "RegisterView", bundle: nil)
        show(secondViewController, sender: nil)

    }
    
    
    @IBAction func iniciarSesion(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) {
                (result, error) in
            
                if let result = result, error == nil{
                    let userID = result.user.uid
                    self.saveUserIDInUserDefault(uid: userID)
                    let homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
                    self.navigationController?.setViewControllers([homeViewController], animated: true)
                }else{
                    let alertController = UIAlertController(title: "Error", message: "Se ha producido un error al iniciar sesion", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }else{
            let alertController = UIAlertController(title: "Error", message: "llena todos los campos", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func signWithGoogle(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
              print("salio mal en primera instancia")
              return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
              print("algo salio mal en el token")
              return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)

        Auth.auth().signIn(with: credential) { result, error in
            
            let id = result?.user.uid
            let name = result?.user.displayName
            self.saveUserDataToFirestore(uid: id, name: name)
        }
        }
        
            
    }
    
    
    
    func isEmpty() -> Bool{
        guard let password = passwordTextField.text,let email = emailTextField.text else{
            return true
        }
        let trimedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return trimedEmail.isEmpty || trimedPassword.isEmpty
    }
    
    
    
    func navigate(){
        let homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
        self.navigationController?.setViewControllers([homeViewController], animated: true)
    }
    
    func saveUserIDInUserDefault(uid: String) {
        UserDefaults.standard.set(true, forKey: "logged")
        UserDefaults.standard.set(uid, forKey: "user")
    }
    
    func checkIfLogged(){
        let logged = UserDefaults.standard.bool(forKey: "logged")
        if(logged == true){
            navigate()
        }
    }

    func saveUserDataToFirestore(uid: String?, name: String?) {
        guard let uid = uid, let name = name else {
            print("UID o nombre nulo")
            return
        }
        let db = Firestore.firestore()
        let userDocument = db.collection("users").document(uid)

        userDocument.getDocument { (document, error) in
            if let document = document, document.exists {
                let homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
                self.navigationController?.setViewControllers([homeViewController], animated: true)
                self.saveUserIDInUserDefault(uid: uid)
            } else {
                let userData: [String: Any] = [
                    "name": name,
                ]
                userDocument.setData(userData) { error in
                    if let error = error {
                        print("Error al guardar datos en Firestore: \(error.localizedDescription)")
                    } else {
                        self.saveUserIDInUserDefault(uid: uid)
                        let homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
                        self.navigationController?.setViewControllers([homeViewController], animated: true)
                    }
                }
            }
        }
    }
}

