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
    
    let data: [[Double]]
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
        return (result)
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
            let indexes = row.enumerated().filter {$0.element == 0}.map{$0.offset}
            for j in indexes {
                if state.colUncovered[j] && state.rowUncovered[i] {
                    state.marked[i][j] = 1
                    state.colUncovered[j] = false
                    state.rowUncovered[i] = false
                }
            }
        }
        state._clearCovers()
        return HungarianStep.step3
    }
    
    func step3(_ state: HungarianState) -> HungarianStep {
        /// Cover each column containing a starred zero. If n columns are covered,
        /// the starred zeros describe a complete set of unique assignments.
        /// In this case, Go to DONE, otherwise, Go to Step 4.
        let flattenMarked = matrixFlatten(state.marked)
        let n = state.marked[0].count
        var count = 0
        for (i, v) in flattenMarked.enumerated() {
            if v == 1 {
                count += 1
                state.colUncovered[i % n] = false
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
        var coveredCopy = matrixFlatten(state.copy)
        for (i,v) in coveredCopy.enumerated() {
            
            coveredCopy[i] = v == 0 ? 1 : 0
            if v == 0 {
                copy[i / m][i % m] = 1
            }
            
            if state.rowUncovered[i / m] == false {
                coveredCopy[i] = 0
            }
            
            if state.colUncovered[i % m] == false {
                coveredCopy[i] = 0
            }
        }
        while true {
            if let maxValue = coveredCopy.max(),
               let maxIndex = coveredCopy.firstIndex(of: maxValue) {
                let row = maxIndex / m
                var col = maxIndex % m

                if coveredCopy[row * m + col] == 0 {
                    return HungarianStep.step6
                    
                } else  {
                    state.marked[row][col] = 2
                    /// Find the first starred element in the row
                    let startCol = state.marked[row].firstIndex(of: 1) != nil ? state.marked[row].firstIndex(of: 1)! : 0
                                
                    if state.marked[row][startCol] != 1 {
                        /// Could not find one
                        state.z0R = row
                        state.z0C = col
                        return HungarianStep.step5
                        
                    } else {
                        col = startCol
                        state.rowUncovered[row] = false
                        state.colUncovered[col] = true
                        for i in 0..<n {
                            
                            if state.rowUncovered[i] == true {
                                coveredCopy[i * m + col] = copy[i][col]
                            } else {
                                coveredCopy[i * m + col] = 0
                            }
                        }
                        for i in 0..<m {
                            coveredCopy[row * m + i] = 0
                        }
                    }
                }
            }
        }
    }
    
    func step5(_ state: HungarianState) -> HungarianStep {
        var count = 0
        var path = state.path
        path[count][0] = Double(state.z0R)
        path[count][1] = Double(state.z0C)
        while true {
            /// Find the first starred element in the col defined by the path
            let transposedMarked = matrixTranspose(state.marked)
        
            let colData = transposedMarked[Int(path[count][1])]
            let rowIndex = colData.firstIndex(of: 1) != nil ? colData.firstIndex(of: 1)! : 0
            
            if state.marked[rowIndex][Int(path[count][1])] != 1 {
                break
            } else {
                count += 1
                path[count][0] = Double(rowIndex)
                path[count][1] = path[count - 1][1]
            }
            
            /// Find the first prime element in the row defined by th first path step
            let rowData = state.marked[Int(path[count][0])]
            var colIndex = rowData.firstIndex(of: 2) != nil ? rowData.firstIndex(of: 2)! : 0
            if state.marked[rowIndex][colIndex] != 2 {
                colIndex = -1
            }
            count += 1
            path[count][0] = path[count - 1][0]
            path[count][1] = Double(colIndex)
        }
        
        /// convert paths
        for i in 0...count {
            if state.marked[Int(path[i][0])][Int(path[i][1])] == 1 {
                state.marked[Int(path[i][0])][Int(path[i][1])] = 0
            } else {
                state.marked[Int(path[i][0])][Int(path[i][1])] = 1
            }
        }
        state._clearCovers()
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
        let rowUncoveredTrueCount = state.rowUncovered.filter{$0 == true}.count
        let colUncoveredTrueCount = state.colUncovered.filter{$0 == true}.count
        
        /// the smallest uncovered value in the matrix
        if rowUncoveredTrueCount > 0 && colUncoveredTrueCount > 0 {
            var minVal = [Double](repeating: Double.greatestFiniteMagnitude, count: state.copy[0].count)
            for (i, isRowCovered) in state.rowUncovered.enumerated() {
                if isRowCovered == true {
                    assert(minVal.count == state.copy[i].count, "minval and copy should have same size, but get minval/copy is \(minVal.count)/\(state.copy[i].count) .")
                    for (j, v) in state.copy[i].enumerated() {
                        minVal[j] = minVal[j] > v ? v : minVal[j]
                    }
                }
            }
            
            var minimum = Double.greatestFiniteMagnitude
            for (i, isColCovered) in state.colUncovered.enumerated() {
                if isColCovered == true {
                    minimum = minimum > minVal[i] ? minVal[i] : minimum
                }
            }
            var copy = state.copy
            for (i, v) in state.rowUncovered.enumerated() {
                if v == false {
                    var c = [Double](repeating: 0, count: state.copy[i].count)
                    vDSP_vsaddD(copy[i], 1, &minimum, &c, 1, vDSP_Length(state.copy[i].count))
                    copy[i] = c
                }
            }
            copy = matrixTranspose(copy)
            minimum = -1 * minimum
            for (i, v) in state.colUncovered.enumerated() {
                if v == true {
                    var c = [Double](repeating: 0, count: copy[i].count)
                    vDSP_vsaddD(copy[i], 1, &minimum, &c, 1, vDSP_Length(copy[i].count))
                    copy[i] = c
                }
            }
            copy = matrixTranspose(copy)
            state.copy = copy
        }
        return HungarianStep.step4
    }
}
