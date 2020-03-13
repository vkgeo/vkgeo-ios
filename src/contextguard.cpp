#include <utility>

#include "contextguard.h"

ContextGuard::ContextGuard() :
    GuardPtr(std::make_shared<bool>(true))
{
}

ContextGuard::ContextGuard(const ContextGuard &other) :
    GuardPtr(other.GuardPtr)
{
}

ContextGuard::ContextGuard(ContextGuard &&other) noexcept :
    GuardPtr(std::move(other.GuardPtr))
{
}

ContextGuard &ContextGuard::operator=(const ContextGuard &other)
{
    GuardPtr = other.GuardPtr;

    return *this;
}

ContextGuard &ContextGuard::operator=(ContextGuard &&other) noexcept
{
    GuardPtr = std::move(other.GuardPtr);

    return *this;
}

ContextGuard::operator bool() const
{
    return GuardPtr && *GuardPtr;
}

void ContextGuard::Invalidate()
{
    if (GuardPtr) {
        *GuardPtr = false;
    }
}
