//
//  MyTest.swift
//  MNISTKit
//
//  Created by Shao-Ping Lee on 3/26/16.
//
//
import Foundation

enum DataFileType {
    case Image
    case Label
}

func loadData() -> ([[Float]], [Int], [[Float]], [Int])? {
    let mainBundle = NSBundle.mainBundle()
    guard let
        trainImagesPath = mainBundle.pathForResource("train-images-idx3-ubyte", ofType: nil),
        trainImageData = NSData(contentsOfFile: trainImagesPath),
        testImagesPath = mainBundle.pathForResource("t10k-images-idx3-ubyte", ofType: nil),
        testImageData = NSData(contentsOfFile: testImagesPath),
        trainLabelsPath = mainBundle.pathForResource("train-labels-idx1-ubyte", ofType: nil),
        trainLabelData = NSData(contentsOfFile: trainLabelsPath),
        testLabelsPath = mainBundle.pathForResource("t10k-labels-idx1-ubyte", ofType: nil),
        testLabelData = NSData(contentsOfFile: testLabelsPath),
        trainImages = imageData(trainImageData),
        testImages = imageData(testImageData),
        trainLabels = labelData(trainLabelData),
        testLabels = labelData(testLabelData) else { return nil }
    
    return (trainImages, trainLabels, testImages, testLabels)
}

func labelData(data: NSData) -> [Int]? {
    let (_, nItem) = readLabelFileHeader(data)
    
    let range = 0..<Int(nItem)
    let extractLabelClosure: (Int) -> UInt8 = { itemIndex in
        return extractLabel(data, labelIndex: itemIndex)
    }
    
    return range.map(extractLabelClosure).map(Int.init)
}

func imageData(data: NSData) -> [[Float]]? {
    guard let (_, nItem, nCol, nRow) = readImageFileHeader(data) else { return nil }
    
    let imageLength = Int(nCol * nRow)
    let range = 0..<Int(nItem)
    let extractImageClosure: (Int) -> [Float] = { itemIndex in
        return extractImage(data, pixelCount: imageLength, imageIndex: itemIndex)
            .map({Float($0)/255})
    }
    
    return range.map(extractImageClosure)
}

func extractImage(data: NSData, pixelCount: Int, imageIndex: Int) -> [UInt8] {
    var byteArray = [UInt8](count: pixelCount, repeatedValue: 0)
    data.getBytes(&byteArray, range: NSRange(location: 16 + imageIndex * pixelCount, length: pixelCount))
    return byteArray
}

func extractLabel(data: NSData, labelIndex: Int) -> UInt8 {
    var byte: UInt8 = 0
    data.getBytes(&byte, range: NSRange(location: 8 + labelIndex, length: 1))
    return byte
}

func readImageFileHeader(data: NSData) -> (UInt32, UInt32, UInt32, UInt32)? {
    let header = readHeader(data, dataType: .Image)
    guard let col = header.2, row = header.3 else { return nil }
    return (header.0, header.1, col, row)
}

func readLabelFileHeader(data: NSData) -> (UInt32, UInt32) {
    let header = readHeader(data, dataType: .Label)
    return (header.0, header.1)
}


func readHeader(data: NSData, dataType: DataFileType) -> (UInt32, UInt32, UInt32?, UInt32?) {
    switch dataType {
    case .Image:
        let headerValues = data.bigEndianInt32s((0..<4))
        return (headerValues[0], headerValues[1], headerValues[2], headerValues[3])
    case .Label:
        let headerValues = data.bigEndianInt32s((0..<2))
        return (headerValues[0], headerValues[1], nil, nil)
    }
}

extension NSData {
    func bigEndianInt32(location: Int) -> UInt32? {
        var value: UInt32 = 0
        self.getBytes(&value, range: NSRange(location: location, length: sizeof(UInt32)))
        return UInt32(bigEndian: value)
    }
    
    func bigEndianInt32s(range: Range<Int>) -> [UInt32] {
        return range.flatMap({bigEndianInt32($0 * sizeof(UInt32))})
    }
}