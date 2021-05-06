//
//  ViewController.swift
//  HungarianAlgorithm
//
//  Created by kehwaweng on 2021/5/6.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let data = [
            [4.0, 1.0, 3.0],
            [2.0, 0.0, 5.0],
            [3.0, 2.0, 2.0]
        ]

        let linear_assignment = HungarianAlgorithm(data: data)
        let result = linear_assignment.forward()
        print(result)
        
    }



}

