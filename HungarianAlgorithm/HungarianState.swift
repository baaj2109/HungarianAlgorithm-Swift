//
//  HungarianState.swift
//  HungarianAlgorithm
//
//  Created by kehwaweng on 2021/5/6.
//

/*
 State of one execution of the Hungarian algorithm.
 Parameters
 ----------
 cost_matrix : 2D matrix
     The cost matrix. Does not have to be square.
 */
internal class HungarianState {
    
    var data: [[Double]]
    var copy: [[Double]]
    var n: Int
    var m: Int
    var row_uncovered: [Bool]
    var col_uncovered: [Bool]
    var z0_r: Int
    var z0_c: Int
    var path: [[Double]]
    var marked: [[Double]]
    var shouldTranspose: Bool
    
    init(data: [[Double]]) {
        
        self.data = data
        
        //  If there are more rows (n) than columns (m), then the algorithm
        //  will not be able to work correctly. Therefore, we
        //  transpose the cost function when needed. Just have to
        //  remember to swap the result columns back later.
        self.shouldTranspose = data[0].count < data.count
        if self.shouldTranspose {
            self.copy = matrixTranspose(data)
        } else {
            self.copy = data
        }
        
        self.n = self.copy.count
        self.m = self.copy[0].count
        
        self.row_uncovered = [Bool](repeating: true, count: self.n)
        self.col_uncovered = [Bool](repeating: true, count: self.m)
        self.z0_r = 0
        self.z0_c = 0
        self.path = [[Double]](repeating: [Double](repeating: 0, count: 2),
                               count: self.n + self.m)
        self.marked = [[Double]](repeating: [Double](repeating: 0, count:  self.m),
                                 count: self.n)
    }
    
    /// Find the first prime element in the specified row. Returns the column index, or -1 if no starred element was found.
    func _find_prime_in_row(row: Int) -> Int {
        var col = self.marked[row].firstIndex(of: 2) != nil ? self.marked[row].firstIndex(of: 2)! : 0
        if marked[row][col] != 2 {
            col = -1
        }
        return col
    }
    
    /// Clear all covered matrix cells
    func _clear_covers() {
        self.row_uncovered = [Bool](repeating: true, count: self.n)
        self.col_uncovered = [Bool](repeating: true, count: self.m)
    }
}

