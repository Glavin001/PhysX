// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Persistent input descriptor and capture into the allocation graph's device-
// conditional continuation. No second graph launch or host decision kernel.
class NativeCorrectionPreparation {
    NativePreparationInputs* mInputs{};
    NativePreparationInputs mHost{};
public:
    void clear(){cudaFree(mInputs);mInputs=nullptr;mHost={};}
    template<class Submit> void initialize(cudaGraph_t body,cudaStream_t stream,Submit submit) {
        allocate(mInputs,1);check(cudaMemsetAsync(mInputs,0,sizeof(*mInputs),stream));
        check(cudaStreamBeginCaptureToGraph(stream,body,nullptr,nullptr,0,cudaStreamCaptureModeThreadLocal));
        try {submit(mInputs);}catch(...) {cudaGraph_t ignored{};cudaStreamEndCapture(stream,&ignored);throw;}
        cudaGraph_t captured{};check(cudaStreamEndCapture(stream,&captured));
    }
    void setInputs(const NativePreparationInputs& inputs,cudaStream_t stream) {
        mHost=inputs;check(cudaMemcpyAsync(mInputs,&mHost,sizeof(mHost),cudaMemcpyHostToDevice,stream));
    }
};
