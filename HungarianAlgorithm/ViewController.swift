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
        
//        let data = [
//            [-44162211308.42038 , -62381390627.02289, -51440060570.86394],
//            [-27638943295.500656, -38752516227.1944 , -32378135848.92763]
//        ]
//        array([[0, 1],
//               [1, 2]])
        
        let data = [
            [0.64529044, 0.05574174, 0.01379997, 0.24818972],
            [0.08347538, 0.79982227, 0.43699732, 0.81953362],
            [0.56925368, 0.54858603, 0.78793364, 0.18776882],
            [0.75609489, 0.93282655, 0.38287491, 0.91874056],
            [0.98723825, 0.26924408, 0.26982105, 0.58733525]
        ]
//        array([[0, 2],
//        [1, 0],
//        [2, 3],
//        [4, 1]])
        
        let linear_assignment = HungarianAlgorithm(data: data)
        let result = linear_assignment.forward()
        print(result)
    }

}

