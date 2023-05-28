//
//  SettingsViewController.swift
//  Alzheimer
//
//  Created by 김태영 on 2023/05/23.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var homeAddressLabel: UILabel!
    
    @IBOutlet weak var emergencyContactLabel: UILabel!
    
    @IBOutlet weak var bloodTypeLabel: UILabel!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var emergencyContact: UITextField!
    
    @IBOutlet weak var homeAddress: UITextField!
    
    @IBOutlet weak var dobButton: UIDatePicker!
    
    @IBOutlet weak var bloodTypePicker: UIPickerView!
    
    let bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        bloodTypePicker.dataSource = self
        bloodTypePicker.delegate = self
        dobButton.datePickerMode = .date

            
        dobButton.maximumDate = Date()
        dobButton.addTarget(self, action: #selector(dateOfBirthButton(_:)), for: .valueChanged)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "goBackToMain"{
            let VC = segue.destination as! ViewController
            saveUserData()
            let dateFormatter = DateFormatter()
            let selectedBType = bloodTypePicker.selectedRow(inComponent: 0)
            
            if name.text?.isEmpty ?? true {
                let alertController = UIAlertController(title: "Empty Name", message: "Please enter a name.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
                return
            }
            if homeAddress.text?.isEmpty ?? true {
                let alertController = UIAlertController(title: "Empty Home Address", message: "Please enter a home address.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
                return
            }
            if emergencyContact.text?.isEmpty ?? true {
                let alertController = UIAlertController(title: "Empty Emergency Contact", message: "Please enter an emergency contact.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
                return
            }
           
            UserDefaults.standard.set(name.text, forKey: "name")
            UserDefaults.standard.set(homeAddress.text, forKey: "homeAddress")
            UserDefaults.standard.set(emergencyContact.text, forKey: "emergencyContact")
            UserDefaults.standard.set(dateFormatter.string(from: dobButton.date), forKey: "dob")
            UserDefaults.standard.set(bloodTypes[selectedBType], forKey: "bloodType")
            
            
            
//            VC.homeAddress = homeAddress.text!
//            VC.emergencyContact = emergencyContact.text!
//            
//            dateFormatter.dateStyle = .short
//            VC.dob = dateFormatter.string(from: dobButton.date)
//            VC.bloodType = bloodTypes[selectedBType]
        }
    }
   
    
    
    
    @IBAction func saveButton(_ sender: Any) {
    }
    
    @IBAction func dateOfBirthButton(_ sender: Any) {
      
    }
    @IBOutlet weak var bloodTypePickerAction: UIPickerView!
    
    
    
    
    func saveUserData() {
        let userDefaults = UserDefaults.standard
        
        // Save the user data using the specified keys
        userDefaults.set(name.text, forKey: "Name")
        userDefaults.set(homeAddress.text, forKey: "HomeAddress")
        userDefaults.set(emergencyContact.text, forKey: "EmergencyContact")
        userDefaults.set(dobButton.date, forKey: "DateOfBirth")
        userDefaults.set(bloodTypePicker.selectedRow(inComponent: 0), forKey: "BloodTypeIndex")
        
        // Synchronize the user defaults
        userDefaults.synchronize()
    }
    
    
}

extension SettingsViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bloodTypes.count
    }
    
}
extension SettingsViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bloodTypes[row]
    }
}

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }

   @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
