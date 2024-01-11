//
//  RegisterView.swift
//  movimania_firebase
//
//  Created by usuario on 27/12/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterView: UIViewController, UITextFieldDelegate {

    var db: Firestore!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
        
        ageTextField.delegate = self
        ageTextField.returnKeyType = .done
        
        emailTextField.delegate = self
        emailTextField.returnKeyType = .done
        
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = .done

    }

    @IBAction func register(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let age = ageTextField.text{
                Auth.auth().createUser(withEmail: email, password: password) {
                    (result, error) in
                
                    if let result = result, error == nil{
                        let userID = result.user
                        self.createUserInFirestore(userID.uid,name,age)
                    }else{
                        let alertController = UIAlertController(title: "Error", message: "Se ha producido un error al registrar el usuario", preferredStyle: .alert)
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
    
    
    func createUserInFirestore(_ id:String,_ name:String,_ age: String){
        var ref: DocumentReference? = nil
        ref = db.collection("users").document(id)
        
        let userData = [
            "name": name,
            "age": age
        ]
        
        ref?.setData(userData){ error in
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: "Hubo un error con el servidor intentalo mas tarde", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                self.present(alertController, animated: true, completion: nil)
            }else{
                let alertController = UIAlertController(title: "Cuenta Creada", message: "Tu cuenta ha sido registrada con exito vuelve al inicio", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default){_ in
                })
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
    
   
    
   

}
