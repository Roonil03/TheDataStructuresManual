# Van Emde Boas Tree

## Overview

A **van Emde Boas (vEB) Tree** is a tree-based data structure that maintains a dynamic set of integers drawn from a fixed universe $U = \{0,1,\dots,u-1\}$, where $u$ is a power of two. It supports the following operations in $O(\log\log u)$ time per operation, making it asymptotically faster than binary search trees or heaps for large universes:

- **Insert(x)**: add element $x$
- **Delete(x)**: remove element $x$
- **Member(x)**: test if $x$ is in the set
- **Successor(x)**: smallest element > $x$
- **Predecessor(x)**: largest element < $x$
- **Minimum()** / **Maximum()**: return the minimum or maximum element


## Structure

Each vEB node for universe size $u$ stores:

- **min**, **max** (integers, $-1$ if empty)
- **summary**: a pointer to a vEB tree of size $\sqrt{u}$ tracking which clusters are nonempty
- **cluster**: an array of $\sqrt{u}$ pointers to vEB trees of size $\sqrt{u}$

Helper functions for an integer $x$:

$$
\mathrm{high}(x) = \left\lfloor \frac{x}{\sqrt{u}} \right\rfloor,\quad
\mathrm{low}(x) = x \bmod \sqrt{u},\quad
\mathrm{index}(h,l) = h\cdot\sqrt{u} + l.
$$

## Operations

### Member(x)

```
if x == V.min or x == V.max: return true
if V.u == 2: return false
return Member(V.cluster[high(x)], low(x))
```


### Minimum(), Maximum()

```
return V.min or V.max
```


### Successor(x)

```
if V.u == 2:
    if x == 0 and V.max == 1: return 1
    else: return -1
if V.min != -1 and x < V.min: return V.min
h, l = high(x), low(x)
if V.cluster[h].max != -1 and l < V.cluster[h].max:
    offset = Successor(V.cluster[h], l)
    return index(h, offset)
succCluster = Successor(V.summary, h)
if succCluster == -1: return -1
return index(succCluster, V.cluster[succCluster].min)
```


### Predecessor(x)

```
if V.u == 2:
    if x == 1 and V.min == 0: return 0
    else: return -1
if V.max != -1 and x > V.max: return V.max
h, l = high(x), low(x)
if V.cluster[h].min != -1 and l > V.cluster[h].min:
    offset = Predecessor(V.cluster[h], l)
    return index(h, offset)
predCluster = Predecessor(V.summary, h)
if predCluster == -1:
    if V.min != -1 and x > V.min: return V.min
    else: return -1
return index(predCluster, V.cluster[predCluster].max)
```


### Insert(x)

```
if V.min == -1:
    V.min = V.max = x; return
if x < V.min: swap(x, V.min)
if V.u > 2:
    h, l = high(x), low(x)
    if V.cluster[h].min == -1:
        Insert(V.summary, h)
        V.cluster[h].min = V.cluster[h].max = l
    else:
        Insert(V.cluster[h], l)
if x > V.max: V.max = x
```


### Delete(x)

```
if V.min == V.max:
    V.min = V.max = -1; return
if V.u == 2:
    if x == 0: V.min = 1 else: V.max = 0; return
if x == V.min:
    first = V.summary.min
    x = index(first, V.cluster[first].min)
    V.min = x
h, l = high(x), low(x)
Delete(V.cluster[h], l)
if V.cluster[h].min == -1:
    Delete(V.summary, h)
if x == V.max:
    if V.summary.max == -1: V.max = V.min
    else:
        smax = V.summary.max
        V.max = index(smax, V.cluster[smax].max)
```


## Time \& Space Complexity

| Operation | Time Complexity |
| :-- | :-- |
| Member | $O(\log\log u)$ |
| Insert | $O(\log\log u)$ |
| Delete | $O(\log\log u)$ |
| Successor | $O(\log\log u)$ |
| Predecessor | $O(\log\log u)$ |
| Minimum/Max | $O(1)$ |

Space usage is $O(u)$ across all clusters and summary nodes.
