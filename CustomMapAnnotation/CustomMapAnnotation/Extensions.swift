//
//  Extensions.swift
//  LocationAudioMessage
//
//  Created by Ho, Tsung Wei on 7/18/18.
//  Copyright © 2018 Michael Ho. All rights reserved.
//

import UIKit

extension UIImage {
    /**
     Create color rectangle as image.
     
     - Parameters:
        - color: the color to be created as an UIImage
        - size:  the size of the UIImage, no need to be set when creating
     */
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil}
        self.init(cgImage: cgImage)
    }
    
    /**
     Clear image.
     
     - Parameters:
        - size:  The size of the UIImage
        - scale: The scale of the output UIImage
     */
    func getClearImage() -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        UIGraphicsPushContext(context)
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        UIGraphicsPopContext()
        guard let outputImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        UIGraphicsEndImageContext()
        
        return  UIImage(cgImage: outputImage.cgImage!, scale: scale, orientation: UIImageOrientation.up)
    }
}

// MARK: - UIImageView
extension UIImageView {
    /**
     Change the color of the image.
     
     - Parameter color: The color to be set to the image.
     */
    func colored(color: UIColor?) {
        guard let color = color else { return }
        self.image = self.image!.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}

// MARK: - UIImage
extension UIImage {
    /**
     Change the color of the image.
     
     - Parameter color: The color to be set to the image.
     */
    public func colored(color: UIColor?) -> UIImage? {
        if let newColor = color {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            
            let context = UIGraphicsGetCurrentContext()!
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.setBlendMode(.normal)
            
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.clip(to: rect, mask: cgImage!)
            
            newColor.setFill()
            context.fill(rect)
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            newImage.accessibilityIdentifier = accessibilityIdentifier
            return newImage
        }
        
        return self
    }
}

// MARK: - UIButton
extension UIButton {
    
    /**
     Init with customized parameters.
     
     - Parameters:
        - frame:        The frame of the button.
        - title:        Title text content.
        - titleColor:   Title color pair. One for normal state and the other one for hightlighted.
        - bgColor:      Background color pair. One for normal state and the other one for hightlighted.
        - cornerRadius: the corner radius of the button. Input value if needs rounded corner.
     */
    public convenience init(frame: CGRect, title: String, titleColor: (UIColor, UIColor) = (UIColor.white, UIColor.gray), bgColor: (UIColor, UIColor) = (UIColor.white, UIColor.gray), cornerRadius: CGFloat? = nil) {
        self.init(frame: frame)
        
        if let cornerRadius = cornerRadius {
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = true
        }
        
        self.setTitle(title, for: UIControlState())
        self.setTitleColor(titleColor.0, for: UIControlState())
        self.setTitleColor(titleColor.1, for: .highlighted)
        self.setBackgroundImage(UIImage(color: bgColor.0), for: .normal)
        self.setBackgroundImage(UIImage(color: bgColor.1), for: .highlighted)
    }
}

// MARK: - UIColor
extension UIColor {
    
    /**
     
     */
    private func RGBtoCMYK(r: CGFloat, g: CGFloat, b: CGFloat) -> (c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) {
        
        if r==0, g==0, b==0 {
            return (0, 0, 0, 1)
        }
        var c = 1 - r
        var m = 1 - g
        var y = 1 - b
        let minCMY = min(c, m, y)
        c = (c - minCMY) / (1 - minCMY)
        m = (m - minCMY) / (1 - minCMY)
        y = (y - minCMY) / (1 - minCMY)
        return (c, m, y, minCMY)
    }
    
    private func CMYKtoRGB(c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let r = (1 - c) * (1 - k)
        let g = (1 - m) * (1 - k)
        let b = (1 - y) * (1 - k)
        return (r, g, b)
    }
    
    public func getDarkColorTint() -> UIColor {
        let ciColor = CIColor(color: self)
        let originCMYK = RGBtoCMYK(r: ciColor.red, g: ciColor.green, b: ciColor.blue)
        let tintRGB = CMYKtoRGB(c: originCMYK.c, m: originCMYK.m, y: originCMYK.y, k: min(1.0, originCMYK.k + 0.15))
        
        return UIColor(red: tintRGB.r, green: tintRGB.g, blue: tintRGB.b, alpha: 1.0)
    }
    
    public func getLtColorTint() -> UIColor {
        let ciColor = CIColor(color: self)
        let originCMYK = RGBtoCMYK(r: ciColor.red, g: ciColor.green, b: ciColor.blue)
        let tintRGB = CMYKtoRGB(c: originCMYK.c, m: originCMYK.m, y: originCMYK.y, k: max(0, originCMYK.k - 0.15))
        
        return UIColor(red: tintRGB.r, green: tintRGB.g, blue: tintRGB.b, alpha: 1.0)
    }
    
    public func getAppropriateTextColor() -> UIColor {
        let ciColor = CIColor(color: self)
        let originCMYK = RGBtoCMYK(r: ciColor.red, g: ciColor.green, b: ciColor.blue)
        if originCMYK.k > 60 {
            return UIColor.darkGray
        } else {
            return UIColor.white
        }
    }
}

extension UIButton {
    
    public func setImageForAllState(image: UIImage){
        self.setImage(image, for: .normal)
        self.setImage(image, for: .highlighted)
        self.setImage(image, for: .selected)
        self.setImage(image, for: .disabled)
        self.setImage(image, for: .focused)
    }
}