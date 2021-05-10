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
        
        
//        let data = [
//            [4.0, 1.0, 3.0],
//            [2.0, 0.0, 5.0],
//            [3.0, 2.0, 2.0]
//        ]
//        array([[0, 1],
//               [1, 0],
//               [2, 2]])

//        let data = [
//            [-27660350448.51619, -31784043413.006424]
//        ]
//        array([[0, 1]])
        
        
//        let data = [
//            [0.20001000000000002, 0.20001000000000002],
//            [0.009166869538691724, 0.20001000000000002]
//        ]
//        array([[0, 1],
//               [1, 0]])
        
//        let data = [
//            [0.20001000000000002],
//            [0.20001000000000002]
//        ]
//        array([[0, 0]])
        
        let data = [
            [-44162211308.42038 , -62381390627.02289, -51440060570.86394],
            [-27638943295.500656, -38752516227.1944 , -32378135848.92763]
        ]
//        array([[0, 1],
//               [1, 2]])
        
        let linear_assignment = HungarianAlgorithm(data: data)
        let result = linear_assignment.forward()
        print(result)
    }

}

