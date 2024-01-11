//
//  MarcadorViewController.swift
//  movimania_firebase
//
//  Created by usuario on 27/12/23.
//

import UIKit
import FirebaseFirestore

class MarcadorViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tabla: UITableView!
    @IBOutlet weak var alertLabel: UILabel!
    
    private let myCountries = ["mexico", "peru", "colombia","japon"]
    
    private var hashmap: [String:String] = [:]
    
    var db:Firestore!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        recoverData()
        tabla.dataSource = self
        tabla.delegate = self
        
        self.title = "Marcador"
        let newHashmap = sortHashMap(hashmaped: hashmap)
        hashmap = newHashmap
        tabla.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "myCustomCell")
        tabla.reloadData()
    }
    func recoverData(){
        let userID = UserDefaults.standard.string(forKey: "user")
        let ref = db.collection("users").document(userID!)
        ref.getDocument{ (document,error) in
            if let document = document, document.exists{
                if let recoverHashmap = document.data()?["puntuaciones"] as? [String:String]{
                    
                    self.hashmap = recoverHashmap
                    
                    self.alertLabel.isHidden = true
                    self.tabla.isHidden = false
                    self.tabla.reloadData()
                }else{
                    print("no se encontro el documento")
                    self.tabla.isHidden = true
                    self.alertLabel.isHidden = false
                }
            }else{
                print("error al obtener el ducumento")
            }
        }
    }
    
    func sortHashMap(hashmaped: [String:String]) -> [String:String] {
        let sortedHashmap = hashmaped.sorted { (entry1, entry2) in
            if let value1 = Int(entry1.value), let value2 = Int(entry2.value) {
                return value1 > value2
            } else {
                return false
            }
        }
        var orderHashmap: [String:String] = [:]
        for (key,value) in sortedHashmap{
            orderHashmap[key] = value
        }
        return orderHashmap
    }
}


extension MarcadorViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hashmap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCustomCell", for: indexPath) as? CustomTableViewCell
        
        let keys = Array(hashmap.keys)
        let scores = Array(hashmap.values)
        
        cell?.gameNameCell.text = keys[indexPath.row]
        cell?.scoreCell.text = scores[indexPath.row]
        cell?.selectionStyle = .none
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tus Puntuaciones"
    }
    
}
