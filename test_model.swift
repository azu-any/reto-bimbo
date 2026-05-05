import Foundation
import CoreML

let url = URL(fileURLWithPath: "Bimbo/AIModel/BimboRegressor.mlmodel")
if let compiledUrl = try? MLModel.compileModel(at: url) {
    let model = try MLModel(contentsOf: compiledUrl)
    print("Inputs:")
    for (name, desc) in model.modelDescription.inputDescriptionsByName {
        print("  \(name): \(desc.type.rawValue)")
    }
    print("Outputs:")
    for (name, desc) in model.modelDescription.outputDescriptionsByName {
        print("  \(name): \(desc.type.rawValue)")
    }
} else {
    print("Failed to compile")
}
