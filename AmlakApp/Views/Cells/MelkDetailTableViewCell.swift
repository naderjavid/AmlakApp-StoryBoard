//
//  MelkDetailTableViewCell.swift
//  AmlakApp
//
//  Created by nader on 6/31/1402 AP.
//

import UIKit

class MelkDetailTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var sharh: UILabel!
    @IBOutlet weak var subCount: UILabel!

    func configureCell(input: MelkDetailEntity) {
        sharh.text = input.sharh
        subCount.text = "\(getMelkDetailAttachmentCount(melkDetailId: Int(input.melkId)))"
        
    }

}
