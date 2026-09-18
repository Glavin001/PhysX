// Experiment only: two-float products with explicit round-to-nearest operations.
// Packed symmetric coefficients share exactly one representation on both sides.
struct CompensatedInverseView {float2* coefficients;int* exponent;unsigned stride;};
__device__ __forceinline__ float2 exactFloatSum(float a,float b){
    const float sum=__fadd_rn(a,b),part=__fsub_rn(sum,a);
    return {sum,__fadd_rn(__fsub_rn(a,__fsub_rn(sum,part)),__fsub_rn(b,part))};
}
// Exact exponent adjustment for normal results. IEEE boundary cases retain
// scalbn semantics; this is numerical range handling, not a backend switch.
__device__ __forceinline__ double scaleBinary(double value,int exponent){
    const unsigned long long bits=__double_as_longlong(value);
    const int old=int((bits>>52)&2047u),next=old+exponent;
    if(old && old<2047 && next>0 && next<2047)
        return __longlong_as_double((bits&0x800fffffffffffffull)|(static_cast<unsigned long long>(next)<<52));
    return scalbn(value,exponent);
}
__device__ __forceinline__ float2 splitDouble(double value){
    const float hi=__double2float_rn(value);return {hi,__double2float_rn(value-double(hi))};
}
__device__ __forceinline__ float2 compensatedProductSum(float2 sum,float2 a,float2 b){
    const float product=__fmul_rn(a.x,b.x);
    float error=__fmaf_rn(a.x,b.x,-product);
    error=__fmaf_rn(a.x,b.y,error);error=__fmaf_rn(a.y,b.x,error);error=__fmaf_rn(a.y,b.y,error);
    const auto added=exactFloatSum(sum.x,product);
    return exactFloatSum(added.x,__fadd_rn(__fadd_rn(sum.y,added.y),error));
}
__global__ void packCompensatedInverse(const double* matrix,CompensatedInverseView out){
    const unsigned node=blockIdx.x*blockDim.x+threadIdx.x;if(node>=out.stride)return;
    double maximum=0;for(unsigned k=0;k<21;++k)maximum=fmax(maximum,fabs(matrix[size_t(k)*out.stride+node]));
    int exponent=0;frexp(maximum,&exponent);out.exponent[node]=exponent;
    for(unsigned k=0;k<21;++k)out.coefficients[size_t(k)*out.stride+node]=splitDouble(scalbn(matrix[size_t(k)*out.stride+node],-exponent));
}
__device__ __forceinline__ StressHierarchy::Vector applyCompensatedInverse(CompensatedInverseView h,unsigned node,StressHierarchy::Vector value){
    const double x[6]={value.angular.x,value.angular.y,value.angular.z,value.linear.x,value.linear.y,value.linear.z};
    double maximum=0;for(unsigned k=0;k<6;++k)maximum=fmax(maximum,fabs(x[k]));
    int exponent=0;frexp(maximum,&exponent);float2 rhs[6];
#pragma unroll
    for(unsigned k=0;k<6;++k)rhs[k]=splitDouble(scaleBinary(x[k],-exponent));
    double out[6];
#pragma unroll
    for(unsigned row=0;row<6;++row){float2 sum{};
#pragma unroll
        for(unsigned col=0;col<6;++col){const unsigned entry=StressHierarchy::triangle(max(row,col),min(row,col));sum=compensatedProductSum(sum,h.coefficients[size_t(entry)*h.stride+node],rhs[col]);}
        out[row]=scaleBinary(double(sum.x)+double(sum.y),exponent+h.exponent[node]);
    }
    return {{out[0],out[1],out[2]},{out[3],out[4],out[5]}};
}
