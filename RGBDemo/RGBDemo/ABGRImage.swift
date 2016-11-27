//
//  ABGRImage.swift
//  Test
//
//  Created by 未央生 on 16/11/24.
//  Copyright © 2016年 未央生. All rights reserved.
//

import UIKit

/* Pixel结构体: 抽象表示一个像素 */
public struct Pixel {
    /* Pixel结构体包括以下几个属性 */
    /* 表示RGBA值，以下几个属性分别表示相应的色阶 */
    public var value: UInt32
    public var red: UInt8 {
        get {
            return UInt8(value & 0xFF)
        }
        set {
            value = UInt32(newValue) | (value & 0xFFFFFF00)
        }
    }
    
    public var green: UInt8 {
        get {
            return UInt8((value >> 8) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF)
        }
    }
    
    public var blue: UInt8 {
        get {
            return UInt8((value >> 16) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF)
        }
    }
    
    public var alpha: UInt8 {
        get {
            return UInt8((value >> 24) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF)
        }
    }
}

class ABGRImage: NSObject {
    /* RGBAImage类的属性 */
    public var pixels: [Pixel]  //代表图形中的所有像素点的集合
    public var width: Int       //代表图形的宽度
    public var height: Int      //代表图形的高度
    
    override init() {
        self.pixels = [Pixel]()
        self.width = 0
        self.height = 0
    }
    
    init?(image:UIImage) {
        guard let cgImage = image.cgImage else { return nil }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        width = Int(image.size.width)
        height = Int(image.size.height)
        let bytesPerRow = width * 4
        
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        imageContext.draw(cgImage, in: CGRect(origin: CGPoint.zero,size:image.size))
        
        let bufferPointer = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
        
        pixels = Array(bufferPointer)
        
        imageData.deinitialize()
        imageData.deallocate(capacity: width * height)
    }
    
    public func toImage() -> UIImage?{
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        let bytesPerRow = width * 4
        
        let imageDataReference = UnsafeMutablePointer<Pixel>(mutating: pixels)
        defer {
            imageDataReference.deinitialize()
        }
        let imageContext = CGContext(data: imageDataReference, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        
        guard let cgImage = imageContext!.makeImage() else {return nil}
        
        let image = UIImage(cgImage: cgImage)
        
        return image
    }
}
extension UIImage{
    func zoom(scle: Int) -> UIImage? {
        let myRGB = ABGRImage.init(image: self)!
        let conversion = ABGRImage.init()
        conversion.width = Int(self.size.width) * scle
        conversion.height = Int(self.size.height) * scle
        
    
        for y in 0..<myRGB.height{
            for _ in 0..<scle {
                for x in 0..<myRGB.width{
                    let index = y*myRGB.height+x
                    let pixel=myRGB.pixels[index]
                    for _ in 0..<scle {
                        conversion.pixels.append(pixel)
                    }
                }
            }
        }
        let newImage = conversion.toImage()
        return newImage
    }
}
