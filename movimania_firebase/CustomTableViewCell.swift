//
//  CustomTableViewCell.swift
//  movimania_firebase
//
//  Created by usuario on 28/12/23.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var gameNameCell: UILabel!
    @IBOutlet weak var scoreCell: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gameNameCell.font = UIFont.boldSystemFont(ofSize: 22)
        scoreCell.font = UIFont.systemFont(ofSize: 18)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        print(gameNameCell.text ?? "vacio")
    }
    
}
