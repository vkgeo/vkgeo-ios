#include <utility>

#include "contextguard.h"

ContextGuard::ContextGuard() :
    InitialInstance(true),
    GuardPtr       (std::make_shared<bool>(true))
{
}

ContextGuard::ContextGuard(const ContextGuard &other) :
    InitialInstance(false),
    GuardPtr       (other.GuardPtr)
{
}

ContextGuard::~ContextGuard() noexcept
{
    if (InitialInstance && GuardPtr) {
        *GuardPtr = false;
    }
}

ContextGuard::operator bool() const
{
    return GuardPtr && *GuardPtr;
}
