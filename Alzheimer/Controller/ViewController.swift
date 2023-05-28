//
//  ViewController.swift
//  Alzheimer
//
//  Created by 김태영 on 2023/05/22.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var informationLabel: UILabel!
    
    @IBOutlet weak var emergencyCallText: UIButton!
    var name = "N/A"
    var homeAddress = "N/A"
    var emergencyContact = "N/A"
    var dob = "N/A"
    var bloodType = "N/A"
    let bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let userDefaults = UserDefaults.standard
        
        // Retrieve the stored user data from UserDefaults
        if let name = userDefaults.string(forKey: "Name") {
            self.name = name
        }
        
        if let homeAddress = userDefaults.string(forKey: "HomeAddress") {
            self.homeAddress = homeAddress
        }
        
        if let emergencyContact = userDefaults.string(forKey: "EmergencyContact") {
            self.emergencyContact = emergencyContact
        }
        
        if let dob = userDefaults.object(forKey: "DateOfBirth") as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            self.dob = dateFormatter.string(from: dob)
        }
        
        if let bloodTypeIndex = userDefaults.object(forKey: "BloodTypeIndex") as? Int {
            self.bloodType = bloodTypes[bloodTypeIndex]
        }
        
        emergencyCallText.setTitle("\(emergencyContact)", for: .normal)
        informationLabel.text = """
        Name: \(name)
        Home address: \(homeAddress)
        Emergency contact: \(emergencyContact)
        Date of birth: \(dob)
        Blood type: \(bloodType)
        """
        informationLabel.numberOfLines = 0
    }

    @IBAction func goToMemoryButton(_ sender: Any) {
    }
    
    @IBAction func goToRepeatButton(_ sender: Any) {
    }
    
    @IBAction func goToSettingsButton(_ sender: Any) {
    }
    
    @IBAction func emergencyCallAction(_ sender: UIButton) {
        if let url = NSURL(string: "tel://" + "\(emergencyContact)"),
           UIApplication.shared.canOpenURL(url as URL){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }

    
}

