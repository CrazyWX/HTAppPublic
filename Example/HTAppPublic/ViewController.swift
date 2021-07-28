//
//  ViewController.swift
//  HTAppPublic
//
//  Created by CrazyWX on 07/26/2021.
//  Copyright (c) 2021 CrazyWX. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc @IBAction func clickToViewController() {
        HTAPPPublicServiceManager.goToAppPublicServiceController {
            //
        } failure: { code, msg in
            //
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

