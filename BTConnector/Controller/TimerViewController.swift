//
//  TimerViewController.swift
//  BTConnector
//
//  Created by NILESH_iOS on 21/03/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

protocol TimerViewControllerDelegate: class {
    func didStartTimer(hour: Int, min: Int, row: Int)
    func didDismissController(_ row: Int)
}

class TimerViewController: UIViewController {

    @IBOutlet var stopTimerBtn: UIButton!
    @IBOutlet var timerPicker: UIPickerView!

    var indexRow: Int?
    var hour = 0
    var min = 0
    weak var delegate: TimerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopTimerBtn.isEnabled = false
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showAlert(with mTitle:String, message:String) {
        let alertContoller = UIAlertController(title: mTitle, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            
        }
        
        alertContoller.addAction(okAction)
        
        self.present(alertContoller, animated: true, completion: nil)
    }
    
    @IBAction func dismissController(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        delegate?.didDismissController(indexRow!)
    }
    
    @IBAction func startTimerBtnTapped(_ sender: UIButton) {
        if hour == 0, min == 0 {
            showAlert(with: "Error in selecting time", message: "Please select proper time")
            return
        }
        delegate?.didStartTimer(hour: hour, min: min, row: indexRow!)
        self.dismiss(animated: true, completion: nil)
    }
}

extension TimerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 24
        case 1:
            return 1
        case 2:
            return 60
        case 3:
            return 1
        default:
            return 0
        }
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        switch component {
//        case 0:
//            return "\(row)"
//        case 1:
//            return "hour"
//        case 2:
//            return "\(row)"
//        case 3:
//            return "min"
//        default:
//            return ""
//        }
//    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 2:
            return 30
        default:
            return 60
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let myTitle: NSAttributedString?
        switch component {
        case 0:
            myTitle = NSAttributedString(string: "\(row)", attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 20.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
            pickerLabel.textAlignment = .right
        case 1:
            myTitle = NSAttributedString(string: "hour", attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 20.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        case 2:
            myTitle = NSAttributedString(string: "\(row)", attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 20.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
            pickerLabel.textAlignment = .right
        case 3:
            myTitle = NSAttributedString(string: "min", attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 20.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        default:
            myTitle = NSAttributedString(string: "", attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 20.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        }
        
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stopTimerBtn.isEnabled = true
        switch component {
        case 0:
            hour = row
        case 2:
            min = row
        default:
            break
        }
    }
}
