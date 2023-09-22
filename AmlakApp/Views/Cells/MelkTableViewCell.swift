//
//  MelkTableViewCell.swift
//  AmlakApp
//
//  Created by nader on 6/31/1402 AP.
//

import UIKit

class MelkTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var subCount: UILabel!

    func configureCell(input: MelkEntity) {
        name.text = "\(input.name ?? "ثبت نشده") | پرونده: \(input.parvandeh) | شماره پلاک: \(input.shamarehPelakSabti ?? "ثبت نشده")"
        subCount.text = "\(getMelkDetailCount(parvandeh: Int(input.parvandeh)))"
        
    }

}
