//
//  ViewController.swift
//  MNISTKit Example iOS
//
//  Created by Shao-Ping Lee on 3/26/16.
//
//

import UIKit
import MNISTKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let (trainImage, trainLabel, testImage, testLabel) = loadData()!
        print(trainImage.count)
        print(trainLabel.count)
        print(testImage.count)
        print(testLabel.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

