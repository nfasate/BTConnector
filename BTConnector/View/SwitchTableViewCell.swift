//
//  SwitchTableViewCell.swift
//  BTConnector
//
//  Created by NILESH_iOS on 21/03/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

protocol SwitchTableCellDelegate: class {
    func didTapTimer(_ row: Int)
    func switchValueChanged(_ row: Int, isOn: Bool)
}

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet var timerBtn: UIButton!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var timerLbl: UILabel!
    @IBOutlet var switchBtn: UISwitch!
    
    weak var delegate: SwitchTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        delegate?.switchValueChanged(sender.tag, isOn: sender.isOn)
    }
    
    @IBAction func timerBtnTapped(_ sender: UIButton) {
        delegate?.didTapTimer(sender.tag)
    }
    
}
