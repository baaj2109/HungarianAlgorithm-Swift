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
    
    let data: [[Double]]
    var copy: [[Double]]
    let n: Int
    let m: Int
    var rowUncovered: [Bool]
    var colUncovered: [Bool]
    var z0R: Int
    var z0C: Int
    let path: [[Double]]
    var marked: [[Double]]
    let shouldTranspose: Bool
    
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
        
        self.rowUncovered = [Bool](repeating: true, count: self.n)
        self.colUncovered = [Bool](repeating: true, count: self.m)
        self.z0R = 0
        self.z0C = 0
        self.path = [[Double]](repeating: [Double](repeating: 0, count: 2),
                               count: self.n + self.m)
        self.marked = [[Double]](repeating: [Double](repeating: 0, count:  self.m),
                                 count: self.n)
    }
    
    /// Find the first prime element in the specified row. Returns the column index, or -1 if no starred element was found.
    func _findPrimeInRow(row: Int) -> Int {
        var col = self.marked[row].firstIndex(of: 2) != nil ? self.marked[row].firstIndex(of: 2)! : 0
        if marked[row][col] != 2 {
            col = -1
        }
        return col
    }
    
    /// Clear all covered matrix cells
    func _clearCovers() {
        self.rowUncovered = [Bool](repeating: true, count: self.n)
        self.colUncovered = [Bool](repeating: true, count: self.m)
    }
}
