//
//  BeaconCell.swift
//  Beacon-Admin
//
//  Created by Jaimin Raval on 08/05/24.
//

import UIKit

protocol BeaconCellDelegate: AnyObject {
    func addMethod(index: Int)
}
class BeaconCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var macLbl: UILabel!
    @IBOutlet weak var uuidLbl: UILabel!
    @IBOutlet weak var majorLbl: UILabel!
    @IBOutlet weak var minorLbl: UILabel!
    
    @IBOutlet weak var addBtn: UIButton!
    
    weak var myDelegate: BeaconCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        

    }

    @IBAction func addBtnTapped(_ sender: Any) {
        myDelegate?.addMethod(index: addBtn.tag)
//        debugPrint("addTapped")
    }
}

