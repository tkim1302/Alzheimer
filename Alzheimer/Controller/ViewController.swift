//
//  ViewController.swift
//  Alzheimer
//
//  Created by 김태영 on 2023/05/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var homeAdrressLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if(homeAdrressLabel.text == nil){
            homeAdrressLabel.text = "No home address is set yet"
        }
        homeAdrressLabel.text = "Homed" 
    }


}

