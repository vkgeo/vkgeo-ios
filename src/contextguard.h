#ifndef CONTEXTGUARD_H
#define CONTEXTGUARD_H

#include <memory>

class ContextGuard
{
public:
    ContextGuard();

    ContextGuard(const ContextGuard &other);
    ContextGuard(ContextGuard &&) noexcept = delete;

    ContextGuard &operator=(const ContextGuard &) = delete;
    ContextGuard &operator=(ContextGuard &&) noexcept = delete;

    virtual ~ContextGuard() noexcept;

    operator bool() const;

private:
    bool                  InitialInstance;
    std::shared_ptr<bool> GuardPtr;
};

#endif // CONTEXTGUARD_H
