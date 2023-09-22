//
//  MelkDetailAttachmentTableViewCell.swift
//  AmlakApp
//
//  Created by nader on 6/31/1402 AP.
//

import UIKit

class MelkDetailAttachmentTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var fileName: UILabel!

    func configureCell(input: MelkDetailAttachmentEntity) {
        fileName.text = input.fileName
        
    }

}
