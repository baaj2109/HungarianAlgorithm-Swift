//
//  HungarianAlgorithm.swift
//  HungarianAlgorithm
//
//  Created by kehwaweng on 2021/5/6.
//

import Accelerate

public enum HungarianStep {
    case step1
    case step3
    case step4
    case step5
    case step6
    case None
}

@available(macOS 10.15, *)
public class HungarianAlgorithm {
    
    public static let INFTY_COST = 1e+5
    
    var data: [[Double]]
    init(data:[[Double]]) {
        self.data = data
    }
    
    public func forward() -> [[Int]] {
        let state = HungarianState(data: self.data)
        var step: HungarianStep
        
        if self.data.count == 0 || self.data[0].count == 0 {
            step = .None
        } else {
            step = .step1
        }
        
        while step != .None {
            switch step {
            case .step1:
                step = step1(state)
            case .step3:
                step = step3(state)
            case .step4:
                step = step4(state)
            case .step5:
                step = step5(state)
            case .step6:
                step = step6(state)
            case .None:
                break
            }
        }
        
        var result = [[Int]]()
        for i in 0..<state.marked.count {
            for j in 0..<state.marked[i].count {
                if state.marked[i][j] == 1 {
                    result.append([i, j])
                }
            }
        }
        if state.shouldTranspose {
            for i in result.indices {
                result[i] = result[i].reversed()
            }
        }
        return result
    }
    
    func step1(_ state: HungarianState) -> HungarianStep {
        /// Step1: For each row of the matrix, find the smallest element and
        /// subtract it from every element in its row.
        for (i,row) in state.copy.enumerated() {
            var min = vDSP.minimum(row) * -1
            var c = [Double](repeating: 0, count: row.count)
            vDSP_vsaddD(row, 1, &min, &c, 1, vDSP_Length(row.count))
            state.copy[i] = c
        }
        /// Step2: Find a zero (Z) in the resulting matrix. If there is no
        /// starred zero in its row or column, star Z. Repeat for each element
        /// in the matrix.
        for (i, row) in state.copy.enumerated() {
            let indexes = row.enumerated().filter { $0.element == 0 }.map{$0.offset}
            for j in indexes {
                if state.col_uncovered[j] && state.row_uncovered[i] {
                    state.marked[i][j] = 1
                    state.col_uncovered[j] = false
                    state.row_uncovered[i] = false
                }
            }
        }
        state._clear_covers()
        return HungarianStep.step3
    }
    
    func step3(_ state: HungarianState) -> HungarianStep {
        /// Cover each column containing a starred zero. If n columns are covered,
        /// the starred zeros describe a complete set of unique assignments.
        /// In this case, Go to DONE, otherwise, Go to Step 4.
        let flatten_marked = matrixFlatten(state.marked)
        let n = state.marked[0].count
        var count = 0
        for (i,v) in flatten_marked.enumerated() {
            if v == 1 {
                count += 1
                state.col_uncovered[i % n] = false
            }
        }
        if count < state.copy.count {
            return HungarianStep.step4
        }
        return HungarianStep.None
    }
    
    func step4(_ state: HungarianState) -> HungarianStep {
        /// Find a noncovered zero and prime it. If there is no starred zero
        /// in the row containing this primed zero, Go to Step 5. Otherwise,
        /// cover this row and uncover the column containing the starred
        /// zero. Continue in this manner until there are no uncovered zeros
        /// left. Save the smallest uncovered value and Go to Step 6.
        
        var copy = [[Double]](repeating: [Double](repeating: 0, count: state.copy[0].count),
                              count: state.copy.count)
        
        let n = state.copy.count
        let m = state.copy[0].count
        var covered_c = matrixFlatten(state.copy)
        for (i,v) in covered_c.enumerated() {
            
            covered_c[i] = v == 0 ? 1 : 0
            if v == 0 {
                copy[i / m][i % m] = 1
            }
            
            if state.row_uncovered[i / m] == false {
                covered_c[i] = 0
            }
            
            if state.col_uncovered[i % m] == false {
                covered_c[i] = 0
            }
        }
        while true {
            if let maxValue = covered_c.max(),
               let maxIndex = covered_c.firstIndex(of: maxValue) {
                let row = maxIndex / m
                var col = maxIndex % m

                if covered_c[row * m + col] == 0 {
                    return HungarianStep.step6
                    
                } else  {
                    state.marked[row][col] = 2
                    /// Find the first starred element in the row
                    let star_col = state.marked[row].firstIndex(of: 1) != nil ? state.marked[row].firstIndex(of: 1)! : 0
                                
                    if state.marked[row][star_col] != 1 {
                        /// Could not find one
                        state.z0_r = row
                        state.z0_c = col
                        return HungarianStep.step5
                        
                    } else {
                        col = star_col
                        state.row_uncovered[row] = false
                        state.col_uncovered[col] = true
                        for i in 0..<n {
                            
                            if state.row_uncovered[i] == true {
                                covered_c[i * n + col] = copy[i][col]
                            } else {
                                covered_c[i * n + col] = 0
                            }
                        }
                        for i in 0..<m {
                            covered_c[row * n + i] = 0
                        }
                    }
                }
            }
        }
    }
    
    func step5(_ state: HungarianState) -> HungarianStep {
        var count = 0
        var path = state.path
        path[count][0] = Double(state.z0_r)
        path[count][1] = Double(state.z0_c)
        while true {
            /// Find the first starred element in the col defined by the path
            let transposed_marked = matrixTranspose(state.marked)
        
            let col_data = transposed_marked[Int(path[count][1])]
            let row_index = col_data.firstIndex(of: 1) != nil ? col_data.firstIndex(of: 1)! : 0
            
            if state.marked[row_index][Int(path[count][1])] != 1 {
                break
            } else {
                count += 1
                path[count][0] = Double(row_index)
                path[count][1] = path[count - 1][1]
            }
            
            /// Find the first prime element in the row defined by th first path step
            let row_data = state.marked[Int(path[count][0])]
            var col_index = row_data.firstIndex(of: 2) != nil ? row_data.firstIndex(of: 2)! : 0
            if state.marked[row_index][col_index] != 2 {
                col_index = -1
            }
            count += 1
            path[count][0] = path[count - 1][0]
            path[count][1] = Double(col_index)
        }
        
        /// convert paths
        for i in 0...count {
            if state.marked[Int(path[i][0])][Int(path[i][1])] == 1 {
                state.marked[Int(path[i][0])][Int(path[i][1])] = 0
            } else {
                state.marked[Int(path[i][0])][Int(path[i][1])] = 1
            }
        }
        state._clear_covers()
        /// Erase all prime markings
        for i in 0..<state.marked.count {
            for j in 0..<state.marked[i].count {
                state.marked[i][j] = state.marked[i][j] == 2 ? 0 : state.marked[i][j]
            }
        }
        return HungarianStep.step3
    }
    

    func step6(_ state: HungarianState) -> HungarianStep {
        /// Add the value found in Step 4 to every element of each covered row,
        /// and subtract it from every element of each uncovered column.
        /// Return to Step 4 without altering any stars, primes, or covered lines.
        let row_uncovered_true_count = state.row_uncovered.filter{ $0 == true}.count
        let col_uncovered_true_count = state.col_uncovered.filter{ $0 == true}.count
        
        /// the smallest uncovered value in the matrix
        if row_uncovered_true_count > 0 && col_uncovered_true_count > 0 {
            var minval = [Double](repeating: Double.greatestFiniteMagnitude, count: state.copy[0].count)
            for (i, is_row_covered) in state.row_uncovered.enumerated() {
                if is_row_covered == true {
                    assert(minval.count == state.copy[i].count, "minval and copy should have same size, but get minval/copy is \(minval.count)/\(state.copy[i].count) .")
                    for (j, v) in state.copy[i].enumerated() {
                        minval[j] = minval[j] > v ? v : minval[j]
                    }
                }
            }
            
            var minimum = Double.greatestFiniteMagnitude
            for (i, is_col_covered) in state.col_uncovered.enumerated() {
                if is_col_covered == true {
                    minimum = minimum > minval[i] ? minval[i] : minimum
                }
            }
            var copy = state.copy
            for (i, v) in state.row_uncovered.enumerated() {
                if v == false {
                    var c = [Double](repeating: 0, count: state.copy[i].count)
                    vDSP_vsaddD(copy[i], 1, &minimum, &c, 1, vDSP_Length(state.copy[i].count))
                    copy[i] = c
                }
            }
            copy = matrixTranspose(copy)
            minimum = -1 * minimum
            for (i, v) in state.col_uncovered.enumerated() {
                if v == true {
                    var c = [Double](repeating: 0, count: state.copy[i].count)
                    vDSP_vsaddD(copy[i], 1, &minimum, &c, 1, vDSP_Length(state.copy[i].count))
                    copy[i] = c
                }
            }
            copy = matrixTranspose(copy)
            state.copy = copy
        }
        return HungarianStep.step4
    }
}
