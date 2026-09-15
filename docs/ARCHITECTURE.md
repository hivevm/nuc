# Architecture — <Project Name>

> The system **as it stands today**: the parts it is built from, what each is responsible for, and
> how they fit together. This document holds no rule and no decision of its own — where a
> structural choice was decided, it names the ADR that decided it, and where it disagrees with an
> accepted ADR, the ADR is right and this document is stale.
>
> It is the third of three: [`SPECIFICATION.md`](SPECIFICATION.md) says what the project is *for*,
> the record in [`adr/`](adr/) says what was decided and *why*, and this document says what
> *exists*. Reconstructing the third from the second is what it exists to spare every reader.
> Decided in [ADR-0001](adr/0001-agent-governance-model.md); it is updated in the same change as the
> structure it describes ([`AGENTS.md` §5](../AGENTS.md#5-quality-bar--definition-of-done)).

## Context

What sits outside the system and what crosses its boundary: the people and neighbouring systems it
talks to, and what flows each way. A diagram earns its place here more than anywhere else in this
document — but no diagram at all beats one that has stopped being true.

TODO — fill in once the system has a boundary worth drawing.

## Building blocks

The parts the system is actually made of, each with one responsibility, named in the vocabulary the
specification defines. Go one level deep, and deeper only where the size of a part earns it: a list
that mirrors the directory tree describes nothing that `ls` does not.

- **<Part>** — what it is responsible for, what it deliberately does not do, and the ADR that
  put it there.

TODO — fill in once there is more than one part.

## How it runs

The few paths worth following end to end — a request, a job, a build — and where state lives
between them. Keep it to the flows a newcomer would otherwise have to reconstruct by reading code;
everything else is better read in the code itself.

TODO — fill in once there is more than one part to connect.
