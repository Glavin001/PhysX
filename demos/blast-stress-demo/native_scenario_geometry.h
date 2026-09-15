// Authored benchmark geometry. No prescribed fractures or solver shortcuts.
#pragma once
#include <string>
#include <stdexcept>
namespace blast_demo {
struct NativeScenarioGeometry {
    std::string name;
    int nx=8, ny=12, nz=8;
    explicit NativeScenarioGeometry(const std::string& kind):name(kind) {
        if(kind=="building")return;
        if(kind=="chain32"){nx=1;ny=32;nz=1;}
        else if(kind=="chain256"){nx=1;ny=256;nz=1;}
        else if(kind=="cantilever64"){nx=64;ny=1;nz=1;}
        else if(kind=="dense12"){nx=12;ny=12;nz=12;}
        else if(kind=="tower64"){nx=8;ny=64;nz=8;}
        else if(kind=="panel32"){nx=32;ny=1;nz=32;}
        else if(kind=="bridge64"){nx=64;ny=4;nz=4;}
        else if(kind=="ladder128"){nx=3;ny=128;nz=1;}
        else throw std::runtime_error("unknown benchmark geometry: "+kind);
    }
    bool present(int x,int y,int z)const {
        if(name=="building" || name=="tower64")
            return x==0 || x==nx-1 || z==0 || z==nz-1 || y%4==0;
        if(name=="ladder128")return x==0 || x==nx-1 || y%4==0;
        if(name=="bridge64")return y==0 || y==ny-1 || z==0 || z==nz-1;
        return true;
    }
    bool supported(int x,int y,int z)const {
        if(name=="cantilever64")return x==0;
        if(name=="panel32")return (x==0 || x==nx-1) && (z==0 || z==nz-1);
        if(name=="bridge64")return x==0 || x==nx-1;
        return y==0;
    }
    bool frame(int x,int y,int z)const {
        return (name=="building" || name=="tower64") &&
            (y%4==0 || ((x==0 || x==nx-1) && (z==0 || z==nz-1)));
    }
    unsigned count()const {
        unsigned n=0;
        for(int y=0;y<ny;++y)for(int z=0;z<nz;++z)for(int x=0;x<nx;++x)n+=present(x,y,z);
        return n;
    }
};
}
