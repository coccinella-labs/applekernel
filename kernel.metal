// SPDX-License-Identifier: MIT
// Copyright (c) 2025 KERNEL.METAL (coccinella-labs)

#include <metal_stdlib>
using namespace metal;

// This is the compute kernel function that performs SAXPY (Single-precision A*X + Y) on the GPU.
// SAXPY: Y = a*X + Y, where a is scalar, X and Y are vectors.
// It takes scalar a, input vector X, input/output vector Y, and count as the number of elements.
// Each thread processes one element of the vectors.
// The thread position in the grid determines which element this thread handles.
// Includes bounds check to prevent out-of-bounds access.
kernel void saxpy(
    // Buffer 0: scalar a
    constant float &a [[buffer(0)]],
    // Buffer 1: input vector X, read-only
    device const float* X [[buffer(1)]],
    // Buffer 2: input/output vector Y
    device float* Y [[buffer(2)]],
    // Buffer 3: element count, constant
    constant uint &count [[buffer(3)]],
    // The global thread ID, used to index into the arrays
    uint id [[thread_position_in_grid]]
) {
    // Bounds check to avoid out-of-bounds access
    if (id >= count) return;
    // Perform SAXPY: Y[id] = a * X[id] + Y[id]
    // This is executed in parallel across all threads
    Y[id] = a * X[id] + Y[id];
}