

import UIKit
import FirebaseFirestore

class SaveGameScore: UIViewController {
    
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var gameName: UITextField!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recuperarInfo()
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    // recupera la puntuacion de la pantalla anterior
    func recuperarInfo(){
        let userScore = UserDefaults.standard.string(forKey: "score")
        score.text = userScore
    }
    // funcion que comprueba si el campo esta vacio y si no lo esta crea o actualiza el documento
    @IBAction func saveScore(_ sender: Any) {
        if let text = gameName.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            if let name = gameName.text{
                let score = score.text
                let id = UserDefaults.standard.string(forKey: "user")
                
                let documentReference = db.collection("users").document(id!)
                documentReference.getDocument { (document, error) in
                    if let document = document, document.exists {
                        var existingData = document.data()?["puntuaciones"] as? [String: Any] ?? [:]
                        
                        // Agregar valor al HashMap existente
                        existingData[name] = score
                        
                        // Actualiza el campo en el documento
                        documentReference.updateData(["puntuaciones": existingData]) { error in
                            if let error = error {
                                //el registro fallo
                                let alertController = UIAlertController(title: "Error", message: "ups hubo un error en el servidor intentalo mas tarde", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                //si el registro fue exitoso
                                let alertController = UIAlertController(title: "BIEN", message: "Puntuación guardada", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default){_ in
                                    self.dismiss(animated: true)
                                })
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    } else {
                        // si no esta creado el hashmap se crea desde 0
                        let hashmap: [String:String] = [
                            name: score!
                        ]
                        var ref: DocumentReference? = nil
                        ref = self.db.collection("users").document(id!)
                        ref?.updateData(["puntuaciones": hashmap]){ error in
                            if error == nil{
                                //si el registro fue exitoso
                                let alertController = UIAlertController(title: "BIEN", message: "Puntuación guardada", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default){_ in
                                    self.dismiss(animated: true)
                                })
                                self.present(alertController, animated: true, completion: nil)
                            }else{
                                //el registro fallo
                                let alertController = UIAlertController(title: "Error", message: "ups hubo un error en el servidor intentalo mas tarde", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }else{
                let alertController = UIAlertController(title: "Error", message: "Asigna un nombre a tu partida", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                self.present(alertController, animated: true, completion: nil)
            }
        }else{
            let alertController = UIAlertController(title: "Error", message: "Asigna un nombre a tu partida", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
