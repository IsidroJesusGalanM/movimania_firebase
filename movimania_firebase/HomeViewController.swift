//
//  HomeViewController.swift
//  movimania_firebase
//
//  Created by usuario on 26/12/23.
//

import UIKit
import CoreData
import FirebaseFirestore

class HomeViewController: UIViewController {

    @IBOutlet weak var pasarAlJuego: UIButton!
    @IBOutlet weak var CerrarSesion: UIButton!
    @IBOutlet weak var userName: UILabel!
    
    var db:Firestore!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        self.title = "MovieMania"
        CerrarSesion.tintColor = .red
        Task{
            _ = await extractData()
        }
    }
    
    @IBAction func pasarAlJuegoButton(_ sender: Any) {
        let secondViewController = juegoMovimania(nibName: "juegoMovimania", bundle: nil)
        show(secondViewController, sender: nil)
    }
    
    @IBAction func pasarAlMarcador(_ sender: Any) {
        let segue = MarcadorViewController(nibName: "MarcadorViewController", bundle: nil)
        show(segue, sender: nil)
    }
    
    
    @IBAction func close(_ sender: Any) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let appDelegate = windowScene.delegate as? SceneDelegate {
            // Crea una instancia del controlador de vista principal del Main.storyboard
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainViewController = mainStoryboard.instantiateInitialViewController() {
                // Establece el controlador de vista principal
                appDelegate.window?.rootViewController = mainViewController
                
                UIView.transition(with: appDelegate.window!, duration: 0.8, options: .transitionCrossDissolve, animations: nil, completion: nil)

            }
        }
        UserDefaults.standard.set(false, forKey: "logged")
        UserDefaults.standard.removeObject(forKey: "user")

    }
    
    func showUIAlert(_ id: String){
        let alertController = UIAlertController(title: "Bien hecho", message: id, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getUIDFromUserDefault() -> String? {
        let id = UserDefaults.standard.string(forKey: "user")
        return id
    }
    
    func setRole(_ role:String){
        self.userName.text = "Hola \(role)!!"
    }

    func extractData() async -> String{
        let user = UserDefaults.standard.string(forKey: "user")
        let refData = db.collection("users").document(user!)
        
        do{
            let document = try await refData.getDocument()
            if document.exists {
                if let role = document.data()?["name"] as? String {
                    setRole(role)
                    return role
                }else{
                    return "sin Datos"
                }
            }else{
                return "nada"
            }
        } catch{
            print("algo salio mal")
            return "nada"
        }
    }
}
