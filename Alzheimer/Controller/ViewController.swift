//
//  ViewController.swift
//  Alzheimer
//
//  Created by 김태영 on 2023/05/22.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var information: UILabel!
    var homeAddress = ""
    var emergencyContact = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if(information.text == nil){
            information.text = "No home address is set yet"
        }
        information.text = "Home"
    }


}

