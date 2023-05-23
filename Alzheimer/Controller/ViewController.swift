//
//  ViewController.swift
//  Alzheimer
//
//  Created by 김태영 on 2023/05/22.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var informationLabel: UILabel!
    
    var name = ""
    var homeAddress = ""
    var emergencyContact = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        if(name == ""){
            informationLabel.text = "Not yet"
        }else{
            informationLabel.text = name
        }
        
    }

    @IBAction func goToMemoryButton(_ sender: Any) {
    }
    
    @IBAction func goToRepeatButton(_ sender: Any) {
    }
    
    @IBAction func goToSettingsButton(_ sender: Any) {
    }
    
}

