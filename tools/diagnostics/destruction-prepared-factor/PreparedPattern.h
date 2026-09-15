#pragma once
// Immutable, coefficient-complete producer plan. Built once from an authored
// operator; GPU consumers supply current bond liveness and anchored membership.
#include "StressSharedFactorPlan.h"

namespace PreparedStress {
struct CoefficientTerm {
    std::uint32_t bond;
    double value;
};
struct SymbolicPattern {
    std::uint32_t nodeCount = 0, bondCount = 0;
    std::vector<std::int32_t> rowBegin, columns, rowIndices;
    std::vector<std::uint32_t> termBegin;
    std::vector<CoefficientTerm> terms;
};

inline SymbolicPattern preparePattern(const NativeStressFactors::Group& group) {
    using namespace NativeStressFactors;
    require(group.anchored, "Prepared direct operators require an anchored asset");
    require(group.weights.size() <= std::size_t(std::numeric_limits<std::int32_t>::max()/6), "Prepared row overflow");
    for (auto weight : group.weights)
        require(weight[0] > 0 && weight[1] > 0, "Prepared node must have six positive weights");
    SymbolicPattern result;
    result.nodeCount = std::uint32_t(group.weights.size());
    result.bondCount = std::uint32_t(group.bonds.size());
    std::vector<std::map<std::int32_t, std::vector<CoefficientTerm>>> rows(6*result.nodeCount);
    for (std::uint32_t edge=0; edge<result.bondCount; ++edge) {
        const auto& bond = group.bonds[edge];
        auto first = block(group,bond.first,bond.offset0,double(bond.scale));
        auto second = block(group,bond.second,bond.offset1,-double(bond.scale));
        for (int column=0; column<6; ++column) {
            std::array<std::pair<std::int32_t,double>,12> entries;
            unsigned count=0;
            for (int side=0; side<2; ++side) {
                const auto node=side?bond.second:bond.first;
                const auto& value=side?second:first;
                if (node<0) continue;
                for (int row=0; row<6; ++row)
                    if (value[6*row+column]!=0) entries[count++]={6*node+row,value[6*row+column]};
            }
            for (unsigned i=0;i<count;++i) for (unsigned j=0;j<count;++j)
                rows[entries[i].first][entries[j].first].push_back({edge,entries[i].second*entries[j].second});
        }
    }
    result.rowBegin.push_back(0);
    result.termBegin.push_back(0);
    for (std::int32_t row=0; row<std::int32_t(rows.size()); ++row) {
        rows[row][row]; // Keep an identity slot even if all incident edges die.
        for (const auto& entry : rows[row]) {
            // Keep cancellation zeros: a later cut can expose these entries.
            result.columns.push_back(entry.first);
            result.rowIndices.push_back(row);
            result.terms.insert(result.terms.end(),entry.second.begin(),entry.second.end());
            require(result.terms.size()<std::size_t(std::numeric_limits<std::uint32_t>::max()),"Prepared term overflow");
            result.termBegin.push_back(std::uint32_t(result.terms.size()));
        }
        require(result.columns.size()<std::size_t(std::numeric_limits<std::int32_t>::max()),"Prepared column overflow");
        result.rowBegin.push_back(std::int32_t(result.columns.size()));
    }
    return result;
}
} // namespace PreparedStress
