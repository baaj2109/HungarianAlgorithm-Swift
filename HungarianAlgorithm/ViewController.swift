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
//            [4.0, 1.0, 3.0],
//            [2.0, 0.0, 5.0],
//            [3.0, 2.0, 2.0]
            [0.20001000000000002, 0.20001000000000002],
            [0.009166869538691724, 0.20001000000000002]
        ]
//        let data = [
//            [-27660350448.51619, -31784043413.006424]
//        ]

        let linear_assignment = HungarianAlgorithm(data: data)
        let result = linear_assignment.forward()
        print(result)
        
    }



}

