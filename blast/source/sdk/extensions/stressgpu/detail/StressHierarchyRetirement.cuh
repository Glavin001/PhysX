// A preconditioner component terminates at one level. Physical topology is
// untouched; subsequent compact levels omit only its numerical coarse work.
struct TerminalRetirement {const unsigned* owner=nullptr;unsigned level=Invalid;const Status* status=nullptr;};
template<bool Retire>
__device__ __forceinline__ bool packingRootRetained(const Input& input,Buffers parent,unsigned root,TerminalRetirement retired){
    if(parent.leader[root]!=root || !parent.coarseActive[root])return false;
    if constexpr(Retire)return retired.owner[input.component[root]]!=retired.level;
    return true;
}
template<bool Retire>
__device__ __forceinline__ bool packingBondRetained(const Input& input,Buffers parent,unsigned bond,TerminalRetirement retired){
    const auto e=parent.coarse[bond];if(!retainedColumn(e))return false;
    if constexpr(Retire){const unsigned root=e.a!=Invalid?e.a:e.b;return retired.owner[input.component[root]]!=retired.level;}
    return true;
}
