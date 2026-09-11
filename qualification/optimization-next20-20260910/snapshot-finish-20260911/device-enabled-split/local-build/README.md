# Local working-build verification

The five frozen GPU implementation files from 8589185e were applied only after
checking their pre-candidate hashes. The normal CMake runtime target rebuilt
successfully; existing snapshot serialization class-memaccess compiler warnings
remain. Local runtime SHA256:
`6592867fe95f5cb642eb84666a67cb9087a5548fe7187379a6bfe9f383e2a5bf`.
Different compilation paths produce a different module hash from the isolated
candidate. Source manifests and the exact build output are retained here.

The local rebuilt runtime passes the unchanged native 29-case correction test
under normal asynchronous memcheck with zero errors. Four representative inputs
pass two independent restored ticks each and the physical observation comparison
against the fully qualified isolated binary: dense interconnections, cold ladder,
11,100-chunk initial impact, and 113,664-chunk late debris. Persistent state and
loads are exact; forces and rigid state use existing bounds. These are correctness
checks, not new performance samples. The upstream GPU activity module and probe
are unchanged and their loaded hashes are recorded in every receipt.

The first post-build helper attempts had a wrong GPU library filename, then
passed file paths where comparison directories were required, and omitted the
observation-export environment setting. No simulation or memory failure occurred.
Failed checker receipts remain here; a new observed capture corrected the wrapper
configuration without changing production code or tolerances. Successful prior
correction memcheck was reused. The final helper records the exact commands and
sets observation export outside the measured tick.

Local source/runtime now contain the fix; installed SDK and frozen N13 artifacts
are unchanged. No deployment or broader optimization acceptance is implied.
