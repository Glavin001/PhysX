#pragma once
// Exact coefficient planning for a future native shared-factor path.
// Not connected to the runtime yet. Inputs are asset coefficients plus current
// component membership/live bonds; loads, solver guesses and damage integration
// deliberately have no role in matrix identity.
#include <array>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <limits>
#include <map>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

namespace NativeStressFactors {
constexpr std::uint32_t noComponent = ~std::uint32_t(0);
struct Node { float angularWeight, linearWeight; std::uint32_t component; };
struct Bond {
    std::uint32_t first, second;
    std::array<float,3> offset0, offset1;
    float health, scale;
};
struct Member {
    std::uint32_t component;
    std::vector<std::uint32_t> nodes, bonds;
};
struct LocalBond {
    std::int32_t first, second;
    std::array<float,3> offset0, offset1;
    float scale;
};
struct Group {
    bool anchored = false;
    std::vector<std::array<float,2>> weights;
    std::vector<LocalBond> bonds;
    std::vector<Member> members;
};
struct Csr {
    std::int32_t rows = 0;
    std::vector<std::int32_t> begin, columns;
    std::vector<double> values;
};
inline void require(bool value, const char* message) {
    if (!value) throw std::runtime_error(message);
}
inline void appendWord(std::string& key, std::uint32_t value) {
    for (unsigned i=0;i<4;++i) key.push_back(char((value>>(8*i))&255));
}
inline void appendFloat(std::string& key, float value) {
    std::uint32_t bits; static_assert(sizeof(bits)==sizeof(value),"FP32 required");
    std::memcpy(&bits,&value,sizeof(bits));appendWord(key,bits);
}
// Sufficient equality, not graph-isomorphism detection. Stable global ID order
// defines a canonical local order. A hash collision cannot alias coefficients:
// unordered_map compares the complete explicit byte string after hashing.
inline std::vector<Group> plan(const std::vector<Node>& nodes, const std::vector<Bond>& bonds) {
    require(nodes.size()<=std::size_t(std::numeric_limits<std::int32_t>::max()/6),"factor row index overflow");
    require(bonds.size()<std::size_t(std::numeric_limits<std::uint32_t>::max()),"factor bond index overflow");
    std::map<std::uint32_t,Member> members;
    std::vector<std::int32_t> local(nodes.size(),-1);
    for (std::uint32_t i=0;i<nodes.size();++i) {
        const auto n=nodes[i];
        require(std::isfinite(n.angularWeight)&&std::isfinite(n.linearWeight)&&n.angularWeight>=0&&n.linearWeight>=0,"invalid node weight");
        if(n.component==noComponent) continue;
        require(n.angularWeight!=0||n.linearWeight!=0,"prescribed node in dynamic component");
        auto& m=members[n.component];m.component=n.component;
        local[i]=std::int32_t(m.nodes.size());m.nodes.push_back(i);
    }
    for(std::uint32_t i=0;i<bonds.size();++i) {
        const auto& e=bonds[i];
        require(e.first<nodes.size()&&e.second<nodes.size()&&e.first!=e.second,"invalid bond endpoints");
        require(std::isfinite(e.health)&&std::isfinite(e.scale),"invalid bond coefficient");
        for(float x:e.offset0) require(std::isfinite(x),"invalid first bond offset");
        for(float x:e.offset1) require(std::isfinite(x),"invalid second bond offset");
        if(e.health<=0||e.scale==0) continue;
        const auto a=nodes[e.first].component,b=nodes[e.second].component;
        require(a==noComponent||b==noComponent||a==b,"live bond crosses dynamic components");
        // Unlabelled dynamic nodes are not prescribed boundaries.
        if(a==noComponent) require(nodes[e.first].angularWeight==0&&nodes[e.first].linearWeight==0,"unlabelled dynamic first endpoint");
        if(b==noComponent) require(nodes[e.second].angularWeight==0&&nodes[e.second].linearWeight==0,"unlabelled dynamic second endpoint");
        const auto id=a==noComponent?b:a;
        if(id!=noComponent) members.at(id).bonds.push_back(i);
    }
    std::vector<Group> groups;
    std::unordered_map<std::string,std::size_t> identities;
    for(auto& entry:members) {
        auto& m=entry.second;
        if(m.bonds.empty()) continue; // No stiffness work to factor.
        Group g;std::string key;
        appendWord(key,std::uint32_t(m.nodes.size()));appendWord(key,std::uint32_t(m.bonds.size()));
        for(auto i:m.nodes) {
            const auto n=nodes[i];g.weights.push_back({n.angularWeight,n.linearWeight});
            appendFloat(key,n.angularWeight);appendFloat(key,n.linearWeight);
        }
        for(auto i:m.bonds) {
            const auto& e=bonds[i];LocalBond v{local[e.first],local[e.second],e.offset0,e.offset1,e.scale};
            g.anchored |= v.first<0||v.second<0;g.bonds.push_back(v);
            appendWord(key,std::uint32_t(v.first));appendWord(key,std::uint32_t(v.second));
            for(float x:v.offset0) appendFloat(key,x);
            for(float x:v.offset1) appendFloat(key,x);
            appendFloat(key,v.scale);
            // Positive health magnitude is material state, not a coefficient
            // of the resident B operator. Liveness and coupling scale are.
        }
        const auto existing=identities.find(key);
        if(existing==identities.end()) {
            g.members.push_back(std::move(m));identities.emplace(std::move(key),groups.size());groups.push_back(std::move(g));
        } else groups[existing->second].members.push_back(std::move(m));
    }
    return groups;
}

// Explicit native B block: diag(node weights) * [I,-skew(r);0,I] * signed scale.
// This is initialization/topology work; it must not be called every hot tick.
inline std::array<double,36> block(const Group& g, std::int32_t node,
                                 const std::array<float,3>& r, double signedScale) {
    std::array<double,36> a{};
    if(node<0) return a;
    for(int i=0;i<6;++i) a[6*i+i]=1;
    a[4]=r[2];a[5]=-double(r[1]);
    a[9]=-double(r[2]);a[11]=r[0];
    a[15]=r[1];a[16]=-double(r[0]);
    for(int row=0;row<6;++row) for(int column=0;column<6;++column)
        a[6*row+column]=(a[6*row+column]*double(g.weights[node][row<3?0:1]))*signedScale;
    return a;
}
inline Csr assemble(const Group& g) {
    require(g.weights.size()<=std::size_t(std::numeric_limits<std::int32_t>::max()/6),"CSR row overflow");
    Csr out;out.rows=std::int32_t(g.weights.size()*6);
    std::vector<std::map<std::int32_t,double>> rows(out.rows);
    for(const auto& e:g.bonds) {
        auto a=block(g,e.first,e.offset0,double(e.scale));
        auto b=block(g,e.second,e.offset1,-double(e.scale));
        for(int column=0;column<6;++column) {
            std::array<std::pair<std::int32_t,double>,12> entries;unsigned count=0;
            for(int side=0;side<2;++side) {
                const auto node=side?e.second:e.first;const auto& v=side?b:a;
                if(node<0) continue;
                for(int row=0;row<6;++row) if(v[6*row+column]!=0)
                    entries[count++]={node*6+row,v[6*row+column]};
            }
            for(unsigned i=0;i<count;++i) for(unsigned j=0;j<count;++j)
                rows[entries[i].first][entries[j].first]+=entries[i].second*entries[j].second;
        }
    }
    out.begin.push_back(0);
    for(const auto& row:rows) {
        for(const auto& x:row) if(x.second!=0) {
            require(std::isfinite(x.second),"nonfinite assembled coefficient");
            require(out.values.size()<std::size_t(std::numeric_limits<std::int32_t>::max()),"CSR entry overflow");
            out.columns.push_back(x.first);out.values.push_back(x.second);
        }
        out.begin.push_back(std::int32_t(out.values.size()));
    }
    return out;
}
} // namespace NativeStressFactors
