//
//  MTFilterManager.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/25.
//

import UIKit
import MetalPetal

class MTFilterManager {
    
    static let shared = MTFilterManager()
    
    var allFilters: [MTFilter.Type] = []
    private var resourceBundle: Bundle
    private var context: MTIContext?
    var device = MTLCreateSystemDefaultDevice()!
    
    init() {
        allFilters.append(MTNormalFilter.self)
        allFilters.append(MTClarendonVideoFilter.self)
        allFilters.append(MTGinghamVideoFilter.self)
        allFilters.append(MTMoonVideoFilter.self)
        allFilters.append(MTLarkFilter.self)
        allFilters.append(MTReyesFilter.self)
        allFilters.append(MTJunoFilter.self)
        allFilters.append(MTSlumberFilter.self)
        allFilters.append(MTCremaFilter.self)
        allFilters.append(MTLudwigFilter.self)
        allFilters.append(MTAdenFilter.self)
        allFilters.append(MTPerpetuaFilter.self)
        allFilters.append(MTAmaroFilter.self)
        allFilters.append(MTMayfairFilter.self)
        allFilters.append(MTRiseFilter.self)
        allFilters.append(MTValenciaFilter.self)
        allFilters.append(MTXpro2Filter.self)
        allFilters.append(MTSierraFilter.self)
        allFilters.append(MTWillowFilter.self)
        allFilters.append(MTLoFiFilter.self)
        allFilters.append(MTInkwellFilter.self)
        
        context = try? MTIContext(device: MTLCreateSystemDefaultDevice()!)
        
        let url = Bundle.main.url(forResource: "FilterAssets", withExtension: "bundle")!
        resourceBundle = Bundle(url: url)!
    }
    
    func url(forResource name: String) -> URL? {
        return resourceBundle.url(forResource: name, withExtension: nil)
    }
    
    func generateThumbnailsForImage(_ image: UIImage, with type: MTFilter.Type) -> UIImage? {
        let filter = type.init()
        
        filter.inputImage = MTIImage(cgImage: image.cgImage!,
                                     options: [.SRGB: false],
                                     isOpaque: true)
        
        if let cgImage = try? context?.makeCGImage(from: filter.outputImage!) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    func generate(image: MTIImage) -> UIImage? {
        if let cgImage = try? context?.makeCGImage(from: image) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
}
