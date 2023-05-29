//
//  AddAlarmViewController.swift
//  Alzheimer
//
//  Created by 김태영 on 2023/05/26.
//

import Foundation
import UIKit

class AddAlarmViewController: UIViewController{
    var models:[String] = []
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var taskInputField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        timePicker.datePickerMode = .time
        self.hideKeyboard() //hiding keyboard function when user tapped any where else on the screen
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //let user to input data and set it in userDefaults.
        if segue.identifier == "goBackToTaskView" {
            let userDefaults = UserDefaults.standard
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            let timeString = formatter.string(from: timePicker.date)
            var timeModels = userDefaults.stringArray(forKey: "Models") ?? []
            timeModels.append(timeString)
            
            if taskInputField.text?.isEmpty ?? true {
                let alertController = UIAlertController(title: "Empty Task", message: "Please enter a task.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
                return
            }
            
            let taskString = taskInputField.text!
            var taskModels = userDefaults.stringArray(forKey: "Tasks") ?? []
            taskModels.append(taskString)
            
            UserDefaults.standard.set(timeModels, forKey: "Models")
            UserDefaults.standard.set(taskModels, forKey: "Tasks")
            userDefaults.synchronize()
        }
    }
    
    
    @IBAction func button(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "Models")
        UserDefaults.standard.removeObject(forKey: "Tasks")
    }
    
}


