/*
 *
 * nbody_GPU_Shared.cu
 *
 * Shared memory-based implementation of the O(N^2) N-body calculation.
 *
 * Copyright (c) 2011-2012, Archaea Software, LLC.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions 
 * are met: 
 *
 * 1. Redistributions of source code must retain the above copyright 
 *    notice, this list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright 
 *    notice, this list of conditions and the following disclaimer in 
 *    the documentation and/or other materials provided with the 
 *    distribution. 
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

#include <chError.h>

#include "bodybodyInteraction.cuh"
#include "nbody_GPU_shared.cuh"

__global__ void
ComputeNBodyGravitation_Shared( 
    float *force, 
    float *posMass, 
    float softeningSquared, 
    size_t N )
{
    ComputeNBodyGravitation_Shared_singleGPU(
        force, 
        posMass, 
        softeningSquared, 
        N );
}

float
ComputeGravitation_GPU_Shared( 
    float *force, 
    float *posMass, 
    float softeningSquared, 
    size_t N )
{
    cudaError_t status;
    cudaEvent_t evStart = 0, evStop = 0;
    float ms = 0.0;
    CUDART_CHECK( cudaEventCreate( &evStart ) );
    CUDART_CHECK( cudaEventCreate( &evStop ) );
    CUDART_CHECK( cudaEventRecord( evStart, NULL ) );
    ComputeNBodyGravitation_Shared<<<300,256, 256*sizeof(float4)>>>( 
        force, 
        posMass, 
        softeningSquared, 
        N );
    CUDART_CHECK( cudaEventRecord( evStop, NULL ) );
    CUDART_CHECK( cudaDeviceSynchronize() );
    CUDART_CHECK( cudaEventElapsedTime( &ms, evStart, evStop ) );
Error:
    CUDART_CHECK( cudaEventDestroy( evStop ) );
    CUDART_CHECK( cudaEventDestroy( evStart ) );
    return ms;
}
