# Deferred registration feed draft

The user explicitly requested the Ranked replacements order: fragment lifecycle,
structural solving, persistent contacts, cluster publication, selective correction,
local activity/topology, remaining passes. The unfinished registration feed belongs
to persistent contacts (#3), so it was removed from production source and preserved
in `deferred-registration-feed.patch` against 7a272166.

This draft is incomplete and has not been built or tested. It adds native contact
allocation/release notifications and a submission interface, but lacks the runtime
implementation and ordered event consumer. It is not a performance improvement or
a finished responsibility. The previously committed GPU allocator/queue remains.
Resume #1 at NpDestructionBodyAllocator, PxgSimulationController and GPU body/shape
installation, preserving ordinary actor/query semantics and accepted publication.
