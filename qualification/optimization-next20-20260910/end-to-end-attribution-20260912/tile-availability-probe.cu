// Compile-only capability probe; not a solver implementation or benchmark.
#include <cuda_tile.h>

__tile_global__ void applyScalarCompliance(double* load, double* inverse,
                                           double* response, std::size_t count)
{
    namespace tile = cuda::tiles;
    using namespace tile::literals;
    auto loads = tile::partition_view{tile::tensor_span{load, tile::extents{count}},
                                      tile::shape{128_ic}};
    auto inverses = tile::partition_view{tile::tensor_span{inverse, tile::extents{count}},
                                         tile::shape{128_ic}};
    auto responses = tile::partition_view{tile::tensor_span{response, tile::extents{count}},
                                          tile::shape{128_ic}};
    auto block = tile::bid().x;
    responses.store_masked(loads.load_masked(block) * inverses.load_masked(block), block);
}
