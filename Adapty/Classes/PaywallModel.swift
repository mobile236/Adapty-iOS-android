//
//  PaywallModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import Foundation

public class PaywallModel: NSObject, JSONCodable, Codable {
    
    enum CodingKeys: String, CodingKey {
        case developerId
        case variationId
        case revision
        case isPromo
        case products
        case visualPaywall
        case internalCustomPayload
    }
    
    @objc public var developerId: String
    @objc public var variationId: String
    @objc public var revision: Int = 0
    @objc public var isPromo: Bool = false
    @objc public var products: [ProductModel] = []
    @objc public var visualPaywall: String = ""
    private var internalCustomPayload: String = ""
    @objc public lazy var customPayload: Parameters = {
        if let data = self.internalCustomPayload.data(using: .utf8), let customPayload = try? JSONSerialization.jsonObject(with: data, options: []) as? Parameters {
            return customPayload
        }
        return Parameters()
    }()
    
    required init?(json: Parameters) throws {
        let attributes: Parameters?
        do {
            attributes = try json.attributes()
        } catch {
            throw error
        }
        
        guard
            let developerId = attributes?["developer_id"] as? String,
            let variationId = attributes?["variation_id"] as? String
        else {
            throw SerializationError.missing("PaywallModel - developer_id, variation_id")
        }
        
        self.developerId = developerId
        self.variationId = variationId
        if let revision = attributes?["revision"] as? Int { self.revision = revision }
        if let isPromo = attributes?["is_promo"] as? Bool { self.isPromo = isPromo }
        if let visualPaywall = attributes?["visual_paywall"] as? String { self.visualPaywall = visualPaywall }
        if let internalCustomPayload = attributes?["custom_payload"] as? String { self.internalCustomPayload = internalCustomPayload }
        
        guard let products = attributes?["products"] as? [Parameters] else {
            throw SerializationError.missing("PaywallModel - products")
        }
        
        var productsArray: [ProductModel] = []
        do {
            try products.forEach { (params) in
                if let product = try ProductModel(json: params) {
                    product.variationId = variationId
                    productsArray.append(product)
                }
            }
        } catch {
            throw SerializationError.invalid("PaywallModel - products", products)
        }
        self.products = productsArray
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? PaywallModel else {
            return false
        }
        
        return self.developerId == object.developerId && self.variationId == object.variationId && self.revision == object.revision && self.isPromo == object.isPromo && self.products == object.products && self.visualPaywall == object.visualPaywall && self.internalCustomPayload == object.internalCustomPayload
    }
    
}

class PaywallsArray: JSONCodable {
    
    var paywalls: [PaywallModel] = []
    var products: [ProductModel] = []
    
    required init?(json: Parameters) throws {
        guard let paywalls = json["data"] as? [Parameters] else {
            return
        }
        
        do {
            try paywalls.forEach { (params) in
                if let paywall = try PaywallModel(json: params) {
                    self.paywalls.append(paywall)
                }
            }
        } catch {
            throw SerializationError.invalid("PaywallsArray - paywalls", paywalls)
        }
        
        guard let meta = json["meta"] as? Parameters, let products = meta["products"] as? [Parameters] else {
            return
        }
        
        do {
            try products.forEach { (params) in
                if let product = try ProductModel(json: params) {
                    self.products.append(product)
                }
            }
        } catch {
            throw SerializationError.invalid("PaywallsArray - products in meta", meta)
        }
    }
    
}
