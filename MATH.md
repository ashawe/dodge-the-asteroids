How to calculate direction from asteroid to where the player is going to be

---

### Starting point: two things must be true at collision time $t$

**The player's future position:**

$$\vec{F} = \vec{P} + \vec{V} \cdot t$$

where $\vec{P}$ = player position, $\vec{V}$ = player velocity.

**The asteroid must reach that point in exactly $t$ seconds.** The asteroid travels at speed $s$ from its own position $\vec{A}$. The distance it covers in $t$ seconds is $s \cdot t$. That distance must equal how far the future point $\vec{F}$ is from the asteroid:

$$|\vec{F} - \vec{A}| = s \cdot t$$

---

### Substituting

Let's call $\vec{D} = \vec{P} - \vec{A}$ (the `relative_pos` in the code — the gap between them right now).

Replace $\vec{F}$:

$$|\vec{P} + \vec{V} \cdot t - \vec{A}| = s \cdot t$$

$$|\vec{D} + \vec{V} \cdot t| = s \cdot t$$

---

### Squaring both sides

The absolute value (distance) is annoying, so square both sides to get rid of it:

$$|\vec{D} + \vec{V} \cdot t|^2 = s^2 \cdot t^2$$

The left side is a dot product with itself: $|\vec{X}|^2 = \vec{X} \cdot \vec{X}$. Expanding:

$$(\vec{D} + \vec{V}t) \cdot (\vec{D} + \vec{V}t) = s^2 t^2$$

Multiply it out (just like $(a+b)^2 = a^2 + 2ab + b^2$, but with vectors):

$$\vec{D} \cdot \vec{D} + 2(\vec{D} \cdot \vec{V})t + (\vec{V} \cdot \vec{V})t^2 = s^2 t^2$$

---

### Rearranging into $at^2 + bt + c = 0$

Move $s^2 t^2$ to the left:

$$(\vec{V} \cdot \vec{V} - s^2)t^2 + 2(\vec{D} \cdot \vec{V})t + \vec{D} \cdot \vec{D} = 0$$

Now match to the code:

| Math | Code | Meaning |
|---|---|---|
| $\vec{V} \cdot \vec{V} - s^2$ | `a = player_vel.length_squared() - asteroid_speed²` | Speed difference squared |
| $2(\vec{D} \cdot \vec{V})$ | `b = 2.0 * relative_pos.dot(player_vel)` | How much the gap is growing/shrinking |
| $\vec{D} \cdot \vec{D}$ | `c = relative_pos.length_squared()` | Current distance squared |

---

### Solving for $t$

This is the standard quadratic formula:

$$t = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$$

The $\pm$ gives two answers (`t1` and `t2`). We want the **smallest positive** one because:
- **Positive** = the collision is in the future, not the past
- **Smallest** = the soonest collision, not some later wrap-around

The `if a != 0.0` guards in the code handle the edge case where both have the same speed ($a = 0$), which makes it a linear equation ($bt + c = 0$, so $t = -c/b$) instead of quadratic.

---

### Finally

Once we have $t$ (e.g., 2.3 seconds), plug it back in:

$$\text{target} = \vec{P} + \vec{V} \cdot t$$

That's mob.gd: `return player_pos + player_vel * t` — the exact spot to aim at.