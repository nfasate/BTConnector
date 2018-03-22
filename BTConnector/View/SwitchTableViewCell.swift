//
//  SwitchTableViewCell.swift
//  BTConnector
//
//  Created by NILESH_iOS on 21/03/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

protocol SwitchTableCellDelegate: class {
    func didTapTimer(_ row: Int, isTimerOn: Bool)
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
        if sender.tintColor != UIColor(red:1.00, green:0.34, blue:0.22, alpha:0.9) {
            //sender.tintColor = UIColor.red
            delegate?.didTapTimer(sender.tag, isTimerOn: true)
        }else {
            //stop timer hereß
            sender.tintColor = UIColor(red:0.41, green:0.95, blue:0.61, alpha:1.0)
            delegate?.didTapTimer(sender.tag, isTimerOn: false)
        }
    }
    
}
