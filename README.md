# trivial-ieee

trivial-ieee provides some very basic functionality for working with IEEE floats.
The motivation for this came from wanting to disable floating-point traps in a portable way,
but there is some other functionality as well.

Currently, it support SBCL, Clozure CL and ECL.

For supported systems it adds `:trivial-ieee` to `*features*`.

## API

### (*WITHOUT-FP-TRAPS* &body body)

Execute body in a context where all floating point traps are disabled. This means
that NaN and Infinity values will be created rather than signaling floating point errors.

### (*DISABLE-FP-TRAPS*)

Globally disables all floating point traps. Not that this library doesn't provide a way to turn
them back on (if they were ever on).

### (*FP-ROUNDING-MODE*)

An setfable accessor for the floating point rounding mode. It can be one of `:nearest`,
`:positive-infinity`, `:negative-infinity`, or `zero`.

### (*INFINITY-P* num)

Predicate to test if `num` is infinite.

### (*NAN-P* num)

Predicate to test if `num` is a NaN.

### *+INF+*

A float value for positive infinity.

### *+NEG-INF+*

A float value for negative infinity.

### *+NAN+*

A float value for a quiet NaN.
