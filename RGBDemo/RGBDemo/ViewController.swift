//
//  ViewController.swift
//  RGBDemo
//
//  Created by 未央生 on 16/11/27.
//  Copyright © 2016年 未央生. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ///添加图片控件，懒加载的
        self.view.addSubview(imageView)
        ///初始化图片
        let image = UIImage(named: "x")
        ///图片放大10倍
        let scaleImage = image?.zoom(scle: 10)
        ///初始化RGB类,里面有一个pixels<Pixel>的数组，里面包括了一个像素的RGB色彩
        let myRGB = ABGRImage.init(image: scaleImage!)!
        ///循环遍历里面每一个像素
        for y in 0..<myRGB.height{
            for x in 0..<myRGB.width{
                let index = y*myRGB.height+x
                var pixel=myRGB.pixels[index]
                if pixel.red > 200 && pixel.green > 200 && pixel.blue > 200 {
                    pixel.red = 255
                    pixel.blue = 0
                    pixel.green = 0
                }
                ///替换对应的RGB色彩
                myRGB.pixels[index] = pixel
            }
        }
        ///生成新图片
        let newImage = myRGB.toImage()
        imageView.image = newImage
    }
    
    ///懒加载
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 20, y: 20, width: 100, height: 100)
        
        return imageView
    }()
    
}

