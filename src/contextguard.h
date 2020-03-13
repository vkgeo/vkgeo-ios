#ifndef CONTEXTGUARD_H
#define CONTEXTGUARD_H

#include <memory>

class ContextGuard
{
public:
    explicit ContextGuard();

    ContextGuard(const ContextGuard &other);
    ContextGuard(ContextGuard &&other) noexcept;

    ContextGuard &operator=(const ContextGuard &other);
    ContextGuard &operator=(ContextGuard &&other) noexcept;

    virtual ~ContextGuard() noexcept = default;

    operator bool() const;

    void Invalidate();

private:
    std::shared_ptr<bool> GuardPtr;
};

#endif // CONTEXTGUARD_H
