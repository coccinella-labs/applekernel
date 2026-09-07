// SPDX-License-Identifier: MIT
// Copyright (c) 2025 KERNEL.METAL (coccinella-labs)

import Metal
import Foundation

// This is the main Swift file for the host code that sets up and runs the Metal compute kernel.
// It initializes Metal, creates buffers, dispatches the kernel, and reads back results.

// Get the default Metal device (the GPU on Apple Silicon)
guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("Metal is not supported on this device")
}

// Read the Metal shader source code from kernel.metal file
let kernelFilePath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("kernel.metal")
let source: String
do {
    source = try String(contentsOf: kernelFilePath, encoding: .utf8)
} catch {
    fatalError("Failed to read kernel.metal file: \(error)")
}

// Create a Metal library from the source code
let library: MTLLibrary
do {
    library = try device.makeLibrary(source: source, options: nil)
} catch {
    fatalError("Failed to create Metal library: \(error)")
}

// Get the compute function named "saxpy" from the library
guard let function = library.makeFunction(name: "saxpy") else {
    fatalError("Failed to find function")
}

// Create the compute pipeline state using the function
let pipelineState: MTLComputePipelineState
do {
    pipelineState = try device.makeComputePipelineState(function: function)
} catch {
    fatalError("Failed to create pipeline state: \(error)")
}

// Define the problem size: 1,000,000 floats
var count: UInt32 = 1_000_000

// SAXPY scalar
var a: Float = 2.0

// Calculate buffer size in bytes
let bufferSize = Int(count) * MemoryLayout<Float>.size

// Create buffers: a (scalar), X, Y
// Using .storageModeShared so CPU and GPU can access them
guard let aBuffer = device.makeBuffer(bytes: &a, length: MemoryLayout<Float>.size, options: .storageModeShared),
      let bufferX = device.makeBuffer(length: bufferSize, options: .storageModeShared),
      let bufferY = device.makeBuffer(length: bufferSize, options: .storageModeShared) else {
    fatalError("Failed to create buffers")
}

// Create buffer for element count
guard let countBuffer = device.makeBuffer(bytes: &count, length: MemoryLayout<UInt32>.size, options: .storageModeShared) else {
    fatalError("Failed to create count buffer")
}

// Fill input buffers X and Y with data
// X[i] = i, Y[i] = i * 2, a = 2.0, so Y[i] should be 2*i + 2*i = 4*i
let pointerX = bufferX.contents().bindMemory(to: Float.self, capacity: Int(count))
let pointerY = bufferY.contents().bindMemory(to: Float.self, capacity: Int(count))
for i in 0..<Int(count) {
    pointerX[i] = Float(i)
    pointerY[i] = Float(i * 2)
}

// Create a command queue for submitting commands to the GPU
guard let commandQueue = device.makeCommandQueue() else {
    fatalError("Failed to create command queue")
}

// Create a command buffer to hold the commands
guard let commandBuffer = commandQueue.makeCommandBuffer() else {
    fatalError("Failed to create command buffer")
}

// Create a compute command encoder to encode compute commands
guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
    fatalError("Failed to create compute encoder")
}

// Set the compute pipeline state on the encoder
computeEncoder.setComputePipelineState(pipelineState)

// Set the buffers on the encoder at their respective indices
computeEncoder.setBuffer(aBuffer, offset: 0, index: 0)
computeEncoder.setBuffer(bufferX, offset: 0, index: 1)
computeEncoder.setBuffer(bufferY, offset: 0, index: 2)
computeEncoder.setBuffer(countBuffer, offset: 0, index: 3)

// Define the thread execution configuration
// Compute optimal dispatch size: round up to multiple of threadgroup size
let tgSize = 256
let numThreads = ((Int(count) + tgSize - 1) / tgSize) * tgSize
let threadsPerGrid = MTLSize(width: numThreads, height: 1, depth: 1)
// threadsPerThreadgroup: number of threads per threadgroup
let threadsPerThreadgroup = MTLSize(width: tgSize, height: 1, depth: 1)

// Dispatch the threads to execute the kernel
computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

// End the compute encoding
computeEncoder.endEncoding()

// Measure execution time
let start = Date()
// Commit the command buffer to execute on the GPU
commandBuffer.commit()
// Wait for the GPU to finish execution
commandBuffer.waitUntilCompleted()
let elapsed = Date().timeIntervalSince(start)
print("Elapsed (s): \(elapsed)")

// Read back the results from buffer Y
let pointerY_result = bufferY.contents().bindMemory(to: Float.self, capacity: Int(count))

// Print sample output to console
print("Sample results:")
// Print first 5 elements
for i in 0..<5 {
    print("Y[\(i)] = \(pointerY_result[i])")
}
print("...")
// Print last 5 elements
for i in (Int(count)-5)..<Int(count) {
    print("Y[\(i)] = \(pointerY_result[i])")
}