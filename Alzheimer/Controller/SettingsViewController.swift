//
//  SettingsViewController.swift
//  Alzheimer
//
//  Created by 김태영 on 2023/05/23.
//

import UIKit

class SettingsViewController: UIViewController {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var homeAddressLabel: UILabel!
    
    @IBOutlet weak var emergencyContactLabel: UILabel!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var emergencyContact: UITextField!
    
    
    @IBOutlet weak var homeAddress: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "goBackToMain"{
            let VC = segue.destination as! ViewController
            if(name.text!.isEmpty){ //if user didn't input their name, the playerName will be stored as "Anonymous"
                VC.name = "Anonymous"
            }else{
                VC.name = name.text!
            }
            VC.homeAddress = homeAddress.text!
            VC.emergencyContact = emergencyContact.text!
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
    }
}
