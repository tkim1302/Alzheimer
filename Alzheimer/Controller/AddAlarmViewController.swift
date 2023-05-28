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
        //label.text  =  models[0]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goBackToTaskView" {
            let userDefaults = UserDefaults.standard
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            let timeString = formatter.string(from: timePicker.date)
            var timeModels = userDefaults.stringArray(forKey: "Models") ?? []
            timeModels.append(timeString)
            
            let taskString = taskInputField.text!
            var taskModels = userDefaults.stringArray(forKey: "Tasks") ?? []
            taskModels.append(taskString)
            
            UserDefaults.standard.set(timeModels, forKey: "Models")
            UserDefaults.standard.set(taskModels, forKey: "Tasks") // Fix the key to "Tasks"
            userDefaults.synchronize()
        }
    }
    
    
    @IBAction func button(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "Models")
        UserDefaults.standard.removeObject(forKey: "Tasks")
    }
    
}


//            let selectedBType = bloodTypePicker.selectedRow(inComponent: 0)
//            if(name.text!.isEmpty){ //if user didn't input their name, the playerName will be stored as "Anonymous"
//                VC.name = "Anonymous"
//            }else{
//                VC.name = name.text!
//            }
//            VC.homeAddress = homeAddress.text!
//            VC.emergencyContact = emergencyContact.text!
            
           // dateFormatter.datePickerMode = .time


//            if let models = UserDefaults.standard.array(forKey: "Models") as? [String] {
//                self.models = models
//            }
            
            
//            if(models.count == 0){
//                models.append(formatter.string(from: timePicker.date))
//               // userDefaults.set(models[0], forKey: "AlarmTime0")
//                UserDefaults.standard.set(models, forKey: "Models")
//                userDefaults.synchronize()
//                label.text = models[0]
//            }else{
//                for i in 1..<VC.models.count + 1{
//                    models.append(formatter.string(from: timePicker.date))
//                //    userDefaults.set(VC.models[i], forKey: "AlarmTime\(i)")
//                    UserDefaults.standard.set(models, forKey: "Models")
//                    userDefaults.synchronize()
//                    label.text = "model \(i) : \(models[i])"
//                }
//            }
