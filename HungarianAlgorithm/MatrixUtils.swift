//
//  MatrixUtils.swift
//  HungarianAlgorithm
//
//  Created by kehwaweng on 2021/5/6.
//

import Accelerate

func matrixTranspose<T>(_ matrix: [[T]]) -> [[T]] {
    if matrix.isEmpty {return matrix}
    var result = [[T]]()
    for index in 0..<matrix.first!.count {
        result.append(matrix.map{$0[index]})
    }
    return result
}


func matrixFlatten<T>(_ data:[[T]]) -> [T] {
    return data.flatMap{ $0 }
}
