#pragma once
#include "PreparedPattern.h"
#include <cuda_runtime.h>

namespace PreparedStress {
struct CoefficientView {
    unsigned nodes, bonds, entries;
    const std::int32_t* rows;
    const std::int32_t* columns;
    const unsigned* termBegin;
    const CoefficientTerm* terms;
    const unsigned* nodeMap;
    const unsigned* bondMap;
};

// A topology producer owns dirty[]. Load changes do not invalidate factors.
// Its caller must provide current, validated anchored membership from the same
// accepted topology, after connectivity and support classification complete.
// Clearing dirty belongs to a successful numeric-factor consumer, not here.
__global__ void produceCurrentCoefficients(CoefficientView plan,
    const float* health, const unsigned* nodeComponent, const unsigned char* anchored,
    const unsigned* dirty, double* exact, float* approximate) {
    const unsigned entry=blockIdx.x*blockDim.x+threadIdx.x, asset=blockIdx.y;
    if(entry>=plan.entries || (dirty && !dirty[asset]))return;
    const unsigned row=plan.rows[entry], column=plan.columns[entry];
    const unsigned a=plan.nodeMap[size_t(asset)*plan.nodes+row/6];
    const unsigned b=plan.nodeMap[size_t(asset)*plan.nodes+column/6];
    const unsigned ca=nodeComponent[a], cb=nodeComponent[b];
    const bool activeA=ca!=~0u && anchored[ca], activeB=cb!=~0u && anchored[cb];
    double value=0;
    if(activeA && activeB) {
        for(unsigned i=plan.termBegin[entry];i<plan.termBegin[entry+1];++i) {
            const auto term=plan.terms[i];
            if(health[plan.bondMap[size_t(asset)*plan.bonds+term.bond]]>0)value+=term.value;
        }
    } else if(!activeA && row==column) value=1;
    const size_t destination=size_t(asset)*plan.entries+entry;
    exact[destination]=value;
    if(approximate)approximate[destination]=float(value);
}
} // namespace PreparedStress
